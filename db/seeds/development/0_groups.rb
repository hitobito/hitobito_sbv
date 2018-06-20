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

def limited(collection)
  Rails.env.development? ? collection.take(4) : collection
end

def build_verein_attrs(parent_id, name)
  { name: name, parent_id: parent_id,
    address: Faker::Address.street_address,
    zip_code: Faker::Address.zip,
    town: Faker::Address.city
  }
end

csv = CSV.parse(Wagons.find('sbv').root.join('db/seeds/development/vereine.csv').read, headers: true)
limited(csv.by_col['Verband'].uniq).each do |name|
  mv = Group::Mitgliederverband.seed(:name, :parent_id, name: name, parent_id: root.id).first

  verein_attrs = csv.select { |row| row['Verband'] == name }.collect do |row|
    build_verein_attrs(mv.id, row['Verein'])
  end

  Group::Verein.seed(:name, :parent_id, limited(verein_attrs))

  mv.default_children.each do |child_class|
    child_class.first.update_attributes(seeder.group_attributes)
  end
end

Group.rebuild!
