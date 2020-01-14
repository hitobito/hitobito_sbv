#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module RoleAbility
    extend ActiveSupport::Concern

    included do
      on(Role) do
        permission(:group_full).may(:create_history_member).in_same_group

        permission(:group_and_below_full).may(:create_history_member).in_same_group_or_below

        permission(:layer_full).may(:create_history_member).in_same_layer

        permission(:layer_and_below_full).
          may(:create_history_member).in_same_layer_or_visible_below

        permission(:layer_and_below_full).
          may(:create, :create_in_subgroup, :update, :destroy).
          in_same_layer_or_visible_below
      end
    end
  end
end
