# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require Rails.root.join('db', 'seeds', 'support', 'person_seeder')

class SbvPersonSeeder < PersonSeeder

  def amount(role_type)
    case role_type.name.demodulize
    when 'Member' then 5
    else 1
    end
  end

end

puzzlers = ['Pascal Zumkehr',
            'Pierre Fritsch',
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
  'Bernhard Lippuner' => 'bernhard.lippuner@windband.ch',
  'Sigi Aulbach' => 'sigi.aulbach@windband.ch',
  'Hans Seeberger' => 'hans.seeberger@windband.ch'
}

puzzlers.each do |puz|
  devs[puz] = "#{puz.split.last.downcase}@puzzle.ch"
end

seeder = SbvPersonSeeder.new

seeder.seed_all_roles

root = Group.root
devs.each do |name, email|
  seeder.seed_developer(name, email, root, Group::Root::Admin)
end
