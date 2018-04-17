# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Group::Root < ::Group

  self.layer = true
  self.default_children = [Group::RootGeschaeftsstelle, 
                           Group::RootVorstand,
                           Group::RootMusikkommission,
                           Group::RootKontakte,
                           Group::RootEhrenmitglieder
                          ]

  children Group::RootGeschaeftsstelle,
           Group::RootVorstand,
           Group::RootMusikkommission,
           Group::RootArbeitsgruppe,
           Group::RootKontakte,
           Group::RootEhrenmitglieder,
           Group::Mitgliederverband

  ### ROLES

  class Admin < Role::Admin
    self.permissions = [:layer_and_below_full, :admin, :impersonation]
  end

  roles Admin

end