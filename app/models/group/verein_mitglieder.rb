# encoding: utf-8

#  Copyright (c) 2012-2013, Puzzle ITC GmbH. This file is part of
#  hitobito_generic and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_generic.

class Group::VereinMitglieder < Group

	children Group::VereinMitglieder

	class Adressverwaltung < Role::Adressverwaltung
	end

	class Mitglied < Role::MitgliederMitglied
	end

	
	class Passivmitglied < Role::MitgliederPassivmitglied
	end

	
	class Ehrenmitglied < Role::Ehrenmitglied
	end

	roles Adressverwaltung, Mitglied, Passivmitglied, Ehrenmitglied
end