# encoding: utf-8

#  Copyright (c) 2018-2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require Rails.root.join('db', 'seeds', 'support', 'group_seeder')

seeder = GroupSeeder.new
mitglieder_verbaende = {}
seed_ran = false

require 'csv'

Group.skip_callback(:create, :before, :set_default_left_and_right)
Group.skip_callback(:save,   :after,  :move_to_new_parent)
Group.skip_callback(:save,   :after,  :set_depth!)
Group.skip_callback(:save,   :after,  :move_to_alphabetic_position)

if Wagons.find('sbv').root.join('db/seeds/production/verbaende.csv').exist?
  CSV.parse(Wagons.find('sbv').root.join('db/seeds/production/verbaende.csv').read, headers: true, converters: :numeric).each do |dachverband|
    next unless dachverband.to_hash['type'] == 'Group::Root'

    Group::Root.seed_once(:name, dachverband.to_hash)

    break # only import the first Dachverband...
  end

  root = Group.roots.first

  CSV.parse(Wagons.find('sbv').root.join('db/seeds/production/verbaende.csv').read, headers: true, converters: :numeric).each do |verband|
    next if verband.to_hash['type'] == 'Group::Root' # we imported that one before

    mv = Group::Mitgliederverband.seed_once(:name, :parent_id, verband.to_hash.merge(parent_id: root.id)).first

    next unless mv

    mv.default_children.each do |child_class|
      child_class.first.update_attributes(seeder.group_attributes)
    end

    mitglieder_verbaende[mv.name] = mv.id # store for verein-import
  end

  seed_ran = true
end

CSV::Converters[:nil] = lambda { |f| f == "\\N" ? nil : f.encode(CSV::ConverterEncoding) rescue f }
CSV::Converters[:all] = [:numeric, :nil]

%w(vereine vereine_musicgest).each do |fn|
  if Wagons.find('sbv').root.join("db/seeds/production/#{fn}.csv").exist?
    CSV.parse(Wagons.find('sbv').root.join("db/seeds/production/#{fn}.csv").read.gsub('\"', '""'), headers: true, converters: :all).each do |verein|
      parent_id = mitglieder_verbaende[verein.delete('verband').last]
      kreis_name = verein.delete('kreis').last

      if kreis_name.present? and verein['swoffice_id'].to_s != '6510'
        Group::Regionalverband.seed_once(
          :name, :parent_id, { parent_id: parent_id, name: kreis_name, type: 'Group::Regionalverband' }
        )
        parent_id = Group::Regionalverband.find_by(name: kreis_name, parent_id: parent_id).id
      end

      vereins_attrs = verein.to_hash.merge(parent_id: parent_id)

      Group::Verein.seed_once(:name, :parent_id, vereins_attrs)
    end

    seed_ran = true
  end
end

Group.set_callback(:create, :before, :set_default_left_and_right)
Group.set_callback(:save,   :after,  :move_to_new_parent)
Group.set_callback(:save,   :after,  :set_depth!)
Group.set_callback(:save,   :after,  :move_to_alphabetic_position)

if seed_ran
  puts "Rebuilding nested set..."
  Group.rebuild!(false)
  puts "Moving Groups in alphabetical order..."
  Group.find_each do |group|
    begin
      group.send(:move_to_alphabetic_position)
    rescue => e
      puts e
      puts group
    end
  end
  puts "Done."
end
