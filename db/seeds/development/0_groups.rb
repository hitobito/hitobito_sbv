# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require Rails.root.join('db', 'seeds', 'support', 'group_seeder')

seeder = GroupSeeder.new
root = Group.roots.first
srand(42)

require 'csv'

def limited(collection, selection: nil)
  if Rails.env.development?
    if selection
      collection & selection
    else
      collection.take(4)
    end
  else
    collection
  end
end

def build_verein_attrs(parent_id, name, besetzung, lang)
  { name: name, parent_id: parent_id,
    address: Faker::Address.street_address,
    zip_code: Faker::Address.zip[0..3],
    town: Faker::Address.city,
    besetzung: besetzung,
    correspondence_language: lang,
  }
end

def build_regionalverband_attrs(parent_id, name = nil)
  build_verein_attrs(parent_id, (name || Faker::Address.city), nil, nil)
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

  rvs = Group::Regionalverband.seed(:name, :parent_id, limited(regionalverband_attrs))

  rvs.each do |rv|
    verein_attrs = csv.select do |row|
      row['Verband'] == name && (row['Regionalverband'] == rv.name || row['Regionalverband'].nil?)
    end.collect do |row|
      build_verein_attrs(rv.id, row['Verein'], row['Besetzung'], row['Amtssprache'])
    end

    Group::Verein.seed(:name, :parent_id, limited(verein_attrs))
  end

  mv.default_children.each do |child_class|
    child_class.first.update_attributes(seeder.group_attributes)
  end
end

Group.rebuild!
