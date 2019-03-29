# rubocop:disable Metrics/BlockLength
namespace :import do
  desc 'Import more historic roles'
  task roles: [:environment] do
    role_csv = Wagons.find('sbv').root.join('db/seeds/production/roles.csv')
    raise unless role_csv.exist?

    require Wagons.find('sbv').root.join('db/seeds/support/data_migrator.rb')
    migrator = DataMigrator.new(role_csv)

    CSV.parse(role_csv.read, headers: true).each do |row|
      person_data = {
        'email'      => row['Adresse e-mail principale'],
        'first_name' => row['Prénom'],
        'last_name'  => row['Nom'],
        'birthday'   => row['Anniversaire']
      }
      person = migrator.load_person(person_data)
      if person.nil?
        puts "Person '#{person_data.values.compact.join(', ')}' nicht gefunden."
        next
      end

      if person.active_years != row["Années d'activité actuelles"].to_i
        puts "Person '#{person}' hat #{person.active_years} " \
             "statt #{row["Années d'activité actuelles"].to_i} Aktivjahren."
        next
      end

      vereins_id = migrator.mitglieder_verein(row['Hitobito-Id'], %w(Mitglieder Membres))
      if vereins_id.nil?
        puts "Mitgliederverein #{row['Hitobito-Id']} / #{row['Verein']} nicht gefunden."
        next
      end

      rolle      = 'Role::MitgliederMitglied'
      entry_date = migrator.parse_date("#{row['Eintritt']}-01-01", default: nil)
      exit_date  = migrator.parse_date("#{row['Austritt']}-12-31", default: nil)

      if entry_date.nil? && exit_date.nil?
        puts 'Fehler im Eintritts- oder Austrittsjahr von ' \
             "Person '#{person_data.values.compact.join(', ')}'."
      end

      Role.new(
        person_id:  person.id,
        group_id:   vereins_id,
        created_at: entry_date,
        deleted_at: exit_date,
        type:       rolle
      ).save(validate: false)
    end
  end
end
