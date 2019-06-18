#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Group::Generalverband < ::Group

  self.layer = true
  self.event_types = [] # only managing structure, does not have events (as of 2019-06-17)

  children Group::Root

  class Admin < Role::Admin
    self.permissions = [:layer_and_below_full, :admin, :impersonation, :finance]
  end

  roles Admin

end
