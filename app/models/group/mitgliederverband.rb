# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Group::Mitgliederverband < ::Group

  self.layer = true
  self.default_children = [Group::MitgliederverbandGeschaeftsstelle,
                           Group::MitgliederverbandVorstand,
                           Group::MitgliederverbandKontakte,
                           Group::MitgliederverbandMusikkommission]

  children Group::MitgliederverbandGeschaeftsstelle,
           Group::MitgliederverbandVorstand,
           Group::MitgliederverbandMusikkommission,
           Group::MitgliederverbandArbeitsgruppe,
           Group::MitgliederverbandKontakte,
           Group::Regionalverband,
           Group::Verein


  ### ROLES

  class Admin < Role::Admin
    self.permissions = [:layer_and_below_full]
  end

  roles Admin
end
