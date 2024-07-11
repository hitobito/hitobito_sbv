# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :import do
  desc "Import more historic roles"
  task roles: [:environment] do
    role_csv = Wagons.find("sbv").root.join("db/seeds/production/roles.csv")
    raise unless role_csv.exist?

    require Wagons.find("sbv").root.join("db/seeds/support/data_migrator.rb")
    migrator = DataMigrator.new(role_csv)

    CSV.parse(role_csv.read, headers: true).each do |row|
      person_data = {
        "email" => row["Adresse e-mail principale"],
        "first_name" => row["Prénom"],
        "last_name" => row["Nom"],
        "birthday" => row["Anniversaire"]
      }
      person = migrator.load_person(person_data)
      if person.nil?
        puts "Person '#{person_data.values.compact.join(", ")}' nicht gefunden."
        next
      end

      if person.active_years != row["Années d'activité actuelles"].to_i
        puts "Person '#{person}' hat #{person.active_years} " \
             "statt #{row["Années d'activité actuelles"].to_i} Aktivjahren."
        next
      end

      vereins_id = migrator.mitglieder_verein(row["Hitobito-Id"], %w[Mitglieder Membres Membre])
      if vereins_id.nil?
        puts "Mitgliederverein #{row["Hitobito-Id"]} / #{row["Verein"]} nicht gefunden."
        next
      end

      rolle = "Role::MitgliederMitglied"
      entry_date = migrator.parse_date("#{row["Eintritt"]}-01-01", default: nil)
      exit_date = migrator.parse_date("#{row["Austritt"]}-12-31", default: nil)

      if entry_date.nil? && exit_date.nil?
        puts "Fehler im Eintritts- oder Austrittsjahr von " \
             "Person '#{person_data.values.compact.join(", ")}'."
        next
      end

      Role.new(
        person_id: person.id,
        group_id: vereins_id,
        created_at: entry_date,
        deleted_at: exit_date,
        type: rolle
      ).save(validate: false)
    end
  end

  desc "Import choirs"
  task choirs: [:environment] do
    choir_csv = Wagons.find("sbv").root.join("db/seeds/production/choirs.csv")
    raise unless choir_csv.exist?

    require Wagons.find("sbv").root.join("db/seeds/support/data_migrator.rb")
    migrator = DataMigrator.new(choir_csv)

    sprachen = Settings.application.languages.to_h

    ActiveRecord::Base.transaction do
      Group.skip_callback(:create, :before, :set_default_left_and_right)
      Group.skip_callback(:save, :after, :move_to_new_parent)
      Group.skip_callback(:save, :after, :set_depth!)
      Group.skip_callback(:save, :after, :move_to_alphabetic_position)

      CSV.parse(
        choir_csv.read(encoding: "ISO-8859-1"),
        headers: true, converters: :numeric, col_sep: ";", quote_char: '"'
      ).each do |choir_row|
        choir = choir_row.to_hash

        kreis_name = choir["Regionalverband"]

        Group::Regionalverband.seed_once(
          :name, { # rubocop:disable Style/BracesAroundHashParameters
            parent_id: Group::Mitgliederverband.first.id,
            name: kreis_name,
            type: "Group::Regionalverband"
          }
        )
        parent = Group::Regionalverband.find_by(name: kreis_name)

        vereins_attrs = {
          parent_id: parent.id,
          name: choir["Verein"],
          description: choir["Status"],
          email: choir["E-Mail"],
          address: choir["Adresse"],
          town: choir["Ort"],
          zip_code: choir["PLZ"],
          country: choir["Land"],
          vereinssitz: choir["Ort"]
        }

        person_attrs = {
          first_name: choir["Vorname"],
          last_name: choir["Nachname"],
          birthday: "1900-01-01",
          email: choir["E-Mail"],
          address: choir["Adresse"],
          town: choir["Ort"],
          zip_code: choir["PLZ"],
          country: choir["Land"],
          correspondence_language: sprachen.key(choir["Sprache der Person"].titlecase)
        }

        Group::Verein.seed_once(:name, :parent_id, vereins_attrs)

        if person_attrs[:email].present?
          Person.seed_once(:email, person_attrs)
        else
          Person.seed(person_attrs)
        end

        person = migrator.load_person(
          person_attrs.stringify_keys,
          birthday_default: migrator.parse_date("1900-01-01"),
          lower_limit: 1899 # to allow the default to be valid
        )
        vereins_id = Group.find_by(name: choir["Verein"]).id

        %w[Privat Mobil].each do |label|
          number = choir["Telefon #{label}"]

          next if number.blank?

          PhoneNumber.seed(
            :contactable_id, :contactable_type, :label,
            contactable_id: person.id,
            contactable_type: person.class.name,
            label: label,
            number: number
          )
        end

        ["Group::Verein::SuisaAdmin", "Group::Verein::Admin"].each do |role_name|
          Role.seed_once(
            :person_id, :group_id, :type,
            person_id: person.id,
            group_id: vereins_id,
            type: role_name
          )
        end
      end

      Group.set_callback(:create, :before, :set_default_left_and_right)
      Group.set_callback(:save, :after, :move_to_new_parent)
      Group.set_callback(:save, :after, :set_depth!)
      Group.set_callback(:save, :after, :move_to_alphabetic_position)

      puts "Rebuilding nested set..."
      Group.rebuild!(false)
    end
  end

  task resort_group: [:environment] do
    puts "Moving Groups in alphabetical order..."
    Group.find_each do |group|
      group.send(:move_to_alphabetic_position)
    rescue => e
      puts e
      puts group
    end
    puts "Done."
  end
end
