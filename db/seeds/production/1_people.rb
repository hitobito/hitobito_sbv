# encoding: utf-8

#  Copyright (c) 2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require Rails.root.join('db', 'seeds', 'support', 'person_seeder')
require 'csv'

puzzlers = ['Pascal Zumkehr',
            'Andreas Maierhofer',
            'Mathis Hofer',
            'Andre Kunz',
            'Pascal Simon',
            'Roland Studer',
            'Matthias Viehweger',
            'Janiss Binder',
            'Bruno Santschi',
          ]

devs = {
  'Sigi Aulbach'       => 'sigi.aulbach@windband.ch',
  'Valentin Bischof'   => 'valentin.bischof@windband.ch',
  'Peter Börlin'       => 'peter.boerlin@windband.ch',
  'Didier Froidevaux'  => 'didier.froidevaux@windband.ch',
  'Heini Füllemann'    => 'heini.fuellemann@windband.ch',
  'Andy Kollegger'     => 'andy.kollegger@windband.ch',
  'Bernhard Lippuner'  => 'bernhard.lippuner@windband.ch',
  'Luana Menoud-Baldi' => 'luana.menoud-baldi@windband.ch',
  'Hans Seeberger'     => 'hans.seeberger@windband.ch',
}

puzzlers.each do |puz|
  devs[puz] = "#{puz.split.last.downcase}@puzzle.ch"
end

vereine = Group.pluck(:name, :id).to_h
mitglieder_ids = {}

if Wagons.find('sbv').root.join("db/seeds/production/mitglieder.csv").exist?
  CSV::Converters[:nil] = lambda { |f| f == "\\N" ? nil : f.encode(CSV::ConverterEncoding) rescue f }
  CSV::Converters[:all] = [:numeric, :nil]

  CSV.parse(Wagons.find('sbv').root.join("db/seeds/production/mitglieder.csv").read.gsub('\"', '""'), headers: true, converters: :all).each do |person|
    person_attrs = person.to_hash

    vereins_name = [person['verein_name'], person['verein_ort']].join(' ')
    verband_name = person['verein_name']

    vereins_id = [vereine[vereins_name], vereine[verband_name]].compact.first

    vereins_mitglieder_id = if vereins_id
                              mitglieder_ids[vereins_id] ||= Group.find(vereins_id).children.where(name: 'Mitglieder').pluck(:id).first
                            else
                              nil
                            end

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
    birthday = begin
                 Date.parse(person['birthday']).to_s
               rescue ArgumentError, TypeError
                 nil
               end

    person_attrs.delete('verein_name')
    person_attrs.delete('verein_ort')
    person_attrs.delete('anrede')
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

    Role.seed_once(:person_id, :group_id, :type, { person_id: db_person.id,
                                                   group_id:  vereins_mitglieder_id,
                                                   type:      'Group::VereinMitglieder::Mitglied' })
  end
end

seeder = PersonSeeder.new

root = Group.root
devs.each do |name, email|
  seeder.seed_developer(name, email, root, Group::Root::Admin)
end
