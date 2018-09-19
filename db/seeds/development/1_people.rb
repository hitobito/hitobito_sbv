# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require Rails.root.join('db', 'seeds', 'support', 'person_seeder')

class SbvPersonSeeder < PersonSeeder

  def amount(role_type)
    case role_type.name
    when 'Group::VereinMitglieder::Mitglied' then Rails.env.development? ? 4 : 20
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
  'Sigi Aulbach'       => 'sigi.aulbach@windband.ch',
  'Valentin Bischof'   => 'valentin.bischof@windband.ch',
  'Peter Börlin'       => 'peter.boerlin@windband.ch',
  'Didier Froidevaux'  => 'didier.froidevaux@windband.ch',
  'Heini Füllemann'    => 'heini.fuellemann@windband.ch',
  'Andy Kollegger'     => 'andy.kollegger@windband.ch',
  'Bernhard Lippuner'  => 'bernhard.lippuner@windband.ch',
  'Luana Menoud-Baldi' => 'luana.menoud-baldi@windband.ch',
  'Hans Seeberger'     => 'hans.seeberger@windband.ch',
  'Norber Kappeler'    => 'info@windband.ch',
  'Didier Bérard'      => 'didier.berard@bluewin.ch',
  'Simon Betschmann'   => 'simon.betschmann@aarg-musikverband.ch',
  'Martin Scherer'     => 'tins@hispeed.ch',
  'Kantonalverband Jura' => 'jp.bendit@jinfo.ch',
  'Julien Schumacher'  => 'julien.schumacher@jesly.ch',
  'Martin Eckenfels'   => 'm.eckenfels@bluewin.ch'
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
