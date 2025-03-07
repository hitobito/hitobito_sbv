#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require Rails.root.join('db', 'seeds', 'support', 'group_seeder')

BESETZUNGEN_MEMO = { 'bb' => 'brass_band',
                     'h' => 'harmonie',
                     'f/b' => 'fanfare_benelux',
                     't/p' => 'fanfare_mixte' }.freeze

Group::Generalverband.seed_once(:name, name: 'hitobito', parent_id: nil)

superstructure = Group::Generalverband.first

Group::Root.seed_once(:parent_id, name: 'SBV', parent_id: superstructure.id)

seeder = GroupSeeder.new
root = Group::Root.order(:id).first
srand(42)

require 'csv'

def limited(collection, selection: nil, limit: nil)
  return collection unless Rails.env.development?
  collection = collection & selection if selection
  collection = collection.take(limit) if limit
  collection
end

def build_verein_attrs(parent_id, name, besetzung, lang)
  attrs = { name: name, parent_id: parent_id,
    street: Faker::Address.street_name,
    housenumber: Faker::Address.building_number,
    zip_code: Faker::Address.zip[0..3],
    town: Faker::Address.city,
    correspondence_language: lang,
  }

  if besetzung
    attrs.merge({
      besetzung: BESETZUNGEN_MEMO.fetch(besetzung, nil),
    })
  end

  attrs
end

def build_kreis_attrs(parent_id, name = nil)
  attrs = []
  (1..4).to_a.sample.times.each do |i|
    attrs << { 
      name: "Kreis " + ['A', 'B', 'C', 'D'][i],
      street: Faker::Address.street_name,
    housenumber: Faker::Address.building_number,
      zip_code: Faker::Address.zip[0..3],
      town: Faker::Address.city,
      parent_id: parent_id
    }
  end
  attrs
end

def build_regionalverband_attrs(parent_id, name = nil)
  build_verein_attrs(parent_id, (name || "Region #{%w[Nord Ost Süd West].sample}"), nil, nil)
end

csv = CSV.parse(Wagons.find('sbv').root.join('db/seeds/development/vereine.csv').read, headers: true)
limited(csv.by_col['Verband'].uniq, selection: [
  'Bernischer Kantonal-Musikverband',
  'St. Galler Blasmusikverband',
  'Société cantonale des musiques fribourgeoises / Freiburger Kantonal-Musikverband',
  'Federazione Bandistica Ticinese',
]).each do |name|
  mv = Group::Mitgliederverband.seed(:name, :parent_id, name: name, parent_id: root.id).first

  regionalverband_attrs = csv.select { |row| row['Verband'] == name }.collect do |row|
    build_regionalverband_attrs(mv.id, row['Regionalverband'])
  end

  rvs = Group::Regionalverband.seed_once(:name, :parent_id, limited(regionalverband_attrs))

  rvs.compact.each do |rv|
    verein_attrs = csv.select do |row|
      row['Verband'] == name && (row['Regionalverband'] == rv.name || row['Regionalverband'].nil?)
    end.collect do |row|
      build_verein_attrs(rv.id, row['Verein'], row['Besetzung'], row['Amtssprache'])
    end

    Group::Verein.seed_once(:name, :parent_id, limited(verein_attrs, limit: 4))
    Group::Kreis.seed_once(:name, :parent_id, build_kreis_attrs(rv.id))
  end

  mv.default_children.each do |child_class|
    child_class.first.update(seeder.group_attributes)
  end
end
