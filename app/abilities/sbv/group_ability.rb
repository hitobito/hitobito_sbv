#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::GroupAbility
  extend ActiveSupport::Concern

  included do
    on(Group) do
      permission(:any).may(:'index_event/festivals').all
      permission(:any).may(:query).all
      permission(:festival_participation).may(:manage_festival_application).in_same_layer
    end
  end
end
