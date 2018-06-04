# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Group::VereinJugend < ::Group

  self.layer = true
  # self.default_children = [Group::VereinVorstand,
  #                          Group::VereinKontakte,
  #                          Group::VereinMitglieder,
  #                          Group::VereinMusikkommission]

  class Vorstand < Group
  end
  class Musikkommission < Group
  end
  # # class Mitglieder < Group::VereinMitglieder ;
  # # class Arbeitsgruppe < Group::VereinArbeitsgruppe ;
  # # class Kontakte < Group::VereinKontakte ;

  children Vorstand

  self.used_attributes += [:founding_year, 
                           :correspondence_language, 
                           :besetzung_value, 
                           :klasse_value, 
                           :unterhaltungsmusik_value, 
                           :subventionen]

  # TODO: Validierungen der verschiedenen Values, refactoring, exports


  ### ROLES

  class Admin < Role::Admin
    self.permissions = [:layer_and_below_full]
  end

  class Mitglied < Role::MitgliederMitglied
    self.permissions = []
  end

  roles Admin, Mitglied
end
