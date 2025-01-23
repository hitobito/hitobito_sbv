# encoding: utf-8

#  Copyright (c) 2018 - 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require Wagons.find('sbv').root.join('db', 'seeds', 'support', 'data_migrator')

require 'csv'
CSV::Converters[:nil] = lambda { |f| f == "\\N" ? nil : f.encode(CSV::ConverterEncoding) rescue f }
CSV::Converters[:all] = [:numeric, :nil]

%w(rollen_musicgest rollen_swoffice rollen_swoffice_admin).each do |fn|
  if Wagons.find('sbv').root.join("db/seeds/production/#{fn}.csv").exist?
    migrator = DataMigrator.new(fn)

    CSV.parse(Wagons.find('sbv').root.join("db/seeds/production/#{fn}.csv").read.gsub('\"', '""'), headers: true, converters: :all).each do |person|

      enough_dates = if migrator.musicgest?
                       entry_date = migrator.parse_date(person['eintrittsdatum'], default: nil)
                       exit_date = migrator.parse_date(person['austrittsdatum'], default: nil)

                       if person['rolle'] == 'Group::VereinMitglieder::Mitglied'
                         entry_date && exit_date
                       else
                         entry_date.present?
                       end
                     else
                       entry_date = migrator.parse_date(person['eintrittsdatum'])
                       exit_date = migrator.parse_date(person['austrittsdatum'], default: nil)

                       entry_date.present?
                     end

      next unless enough_dates

      group_id = case person['rolle']
                 when 'Group::VereinMitglieder::Mitglied'
                   migrator.infer_verein(person['verein_name'], person['verein_ort'], 'Mitglieder')
                 when 'Group::VereinVorstand::Praesident'
                   migrator.infer_verein(person['verein_name'], person['verein_ort'], 'Vorstand')
                 when 'Group::Verein::SuisaAdmin', 'Group::Verein::Admin'
                   migrator.infer_verein(person['verein_name'], person['verein_ort'])

                 end

      next unless group_id

      birthday = migrator.parse_date(person['birthday'], default: nil)

      db_person = if person['email'].present?
                    Person.find_by(email: person['email'])
                  else
                    Person.find_by(
                      first_name: person['first_name'],
                      last_name: person['last_name'],
                      birthday: birthday
                    )
                  end

      next unless db_person

      Role.seed_once( :person_id, :group_id, :type, {
        person_id:  db_person.id,
        group_id:   group_id,
        start_on: entry_date,
        end_on: exit_date,
        type:       person['rolle']
      })
    end
  end
end

puts "Deleting groups that were only needed for migrating the active veteran years..."
Group.without_deleted.where(swoffice_id: -1).find_each do |group|
  group.children.destroy_all
  group.destroy!
end
puts "Done."
