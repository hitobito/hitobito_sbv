# encoding: utf-8

#  Copyright (c) 2012-2013, Puzzle ITC GmbH. This file is part of
#  hitobito_generic and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_generic.

class Group::MitgliederverbandMusikkommission < Group

	class Praesident < Role::MusikkommissionPraesident
	end

	class Mitglied < Role::MusikkommissionMitglied
	end

	roles Praesident, Mitglied
end
