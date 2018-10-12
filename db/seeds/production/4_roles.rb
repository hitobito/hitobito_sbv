# encoding: utf-8

#  Copyright (c) 2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require Wagons.find('sbv').root.join('db', 'seeds', 'support', 'data_migrator')

require 'csv'
CSV::Converters[:nil] = lambda { |f| f == "\\N" ? nil : f.encode(CSV::ConverterEncoding) rescue f }
CSV::Converters[:all] = [:numeric, :nil]


migrator = DataMigrator.new

%w(rollen_musicgest).each do |fn|
  if Wagons.find('sbv').root.join("db/seeds/production/#{fn}.csv").exist?

    CSV.parse(Wagons.find('sbv').root.join("db/seeds/production/#{fn}.csv").read.gsub('\"', '""'), headers: true, converters: :all).each do |person|


      vereins_mitglieder_id = migrator.infer_mitgliederverein(person['verein_name'], person['verein_ort'])

      next unless vereins_mitglieder_id

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
        group_id:   vereins_mitglieder_id,
        created_at: person['eintrittsdatum'],
        deleted_at: person['austrittsdatum'],
        type:       'Group::VereinMitglieder::Mitglied'
      })
    end
  end
end
