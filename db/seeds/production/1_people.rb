# encoding: utf-8

#  Copyright (c) 2018 - 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require Wagons.find('sbv').root.join('db', 'seeds', 'support', 'data_migrator')
require 'csv'

migrator = DataMigrator.new

%w(mitglieder mitglieder_musicgest).each do |fn|
  if Wagons.find('sbv').root.join("db/seeds/production/#{fn}.csv").exist?
    CSV::Converters[:nil] = lambda { |f| f == "\\N" ? nil : f.encode(CSV::ConverterEncoding) rescue f }
    CSV::Converters[:all] = [:numeric, :nil]

    CSV.parse(Wagons.find('sbv').root.join("db/seeds/production/#{fn}.csv").read.gsub('\"', '""'), headers: true, converters: :all).each do |person|
      person_attrs = person.to_hash

      vereins_mitglieder_id = migrator.infer_verein(person['verein_name'], person['verein_ort'], 'Mitglieder')

      gender = case person['anrede']
               when /^Herrn?/, /^Hr\.?$/, /M[o]{1,2}[nh]{0,2}sieu?r/, /Si[gn]{2}[uo]re?/, /Sig\.?/, /^Mr\.?$/, /^M\.?$/
                 'm'
               when /[Frau]{3,4}/, /^Fr/, /Duo?nna?/, /Madamm?e/, 'Mademoiselle', /Sig.+a/, 'Mlle', /^Mme\.?$/, /^Mr?s$/
                 'w'
               else
                 nil
               end
      email = person['email'].presence
      additional_information = [person['bemerkung'], person['zusatz']].join(' ').presence

      birthday = migrator.parse_date(person['birthday'], default: nil)
      role_created_at = migrator.parse_date(person['eintrittsdatum'])

      person_attrs.delete('verein_name')
      person_attrs.delete('verein_ort')
      person_attrs.delete('anrede')
      person_attrs.delete('eintrittsdatum')
      person_attrs.delete('bemerkung')
      person_attrs.delete('zusatz')

      uniqueness = if person['email'].present?
                     [:email]
                   else
                     [:first_name, :last_name, :birthday]
                   end

      Person.seed_once(*uniqueness, person_attrs.merge({
        gender: gender,
        additional_information: additional_information,
        email: email,
        birthday: birthday,
        primary_group_id: vereins_mitglieder_id
      }))

      next unless vereins_mitglieder_id

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

      Role.seed_once(:person_id, :group_id, :type, { person_id:  db_person.id,
                                                     group_id:   vereins_mitglieder_id,
                                                     created_at: role_created_at,
                                                     type:       'Group::VereinMitglieder::Mitglied' })
    end
  end
end
