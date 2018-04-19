# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require Rails.root.join('db', 'seeds', 'support', 'group_seeder')

seeder = GroupSeeder.new

root = Group.roots.first
srand(42)

# TODO: define more groups

mitgliederverbaende =  ["Aargauischer Musikverband",
						"Appenzeller Blasmusikverband",
						"Musikverband beider Basel",
						"Bernischer Kantonal-Musikverband",
						"Freiburger Kantonal-Musikverband",
						"Association cantonale des musiques genevoises",
						"Glarner Blasmusikverband",
						"Graubündner Kantonaler Musikverband",
						"Fédération jurassienne de musique",
						"Luzerner Kantonal-Blasmusikverband",
						"Association cantonale des musiques neuchâteloises",
						"St. Galler Blasmusikverband",
						"Schaffhauser Blasmusikverband",
						"Schwyzer Kantonal Musikverband",
						"Solothurner Blasmusikverband",
						"Federazione Bandistica Ticinese",
						"Thurgauer Kantonal Musik Verband",
						"Unterwaldner Musikverband",
						"Blasmusikverband uri",
						"Kantonaler Musikverband Wallis",
						"Société cantonale des musiques vaudoises",
						"Zuger Blasmusikverband",
						"Zürcher Blasmusikverband",
						"Schweizer Jugendmusikverband",
						"Schweizer Blaukreuzmusikverband",
						"Verband der Musikvereine des Verkehrspersonals der Schweiz",
						"Gardemusik des Vatikans",
						"Schweizerischer Brass Band Verband",
						"Schweizer Militärmusikverband",
						"Schweizer Blasmusik-Dirigentenverband",
						"Association romande des directeurs de musique"
					   ]


mitgliederverbaende.each do |mv|
	Group::Mitgliederverband.seed(:name, :parent_id, {name: mv, parent_id: root.id})
	# mv.default_children.each do |child_class|
	#   child_class.first.update_attributes(seeder.group_attributes)
	# end
end

Group.rebuild!
