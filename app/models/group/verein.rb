# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Group::Verein < ::Group

  self.layer = true
  self.default_children = [ Group::VereinVorstand,
  						              Group::VereinKontakte,
                            Group::VereinMitglieder,
  						              Group::VereinMusikkommission
  						             ]

  children Group::VereinVorstand,
           Group::VereinMusikkommission,
           Group::VereinMitglieder,
           Group::VereinArbeitsgruppe,
           Group::VereinKontakte


  ### ROLES

  class Admin < Role::Admin
    self.permissions = [:layer_and_below_full]
  end

  roles Admin
end