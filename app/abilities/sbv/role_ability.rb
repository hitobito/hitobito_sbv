#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module RoleAbility
    extend ActiveSupport::Concern

    included do
      on(Role) do
        permission(:group_full).may(:create_history_member).in_same_group_or_hidden
        permission(:group_and_below_full)
          .may(:create_history_member)
          .in_same_group_or_below_or_hidden

        permission(:layer_full).may(:create_history_member).in_same_layer_or_hidden
        permission(:layer_and_below_full)
          .may(:create_history_member)
          .in_same_layer_or_visible_below_or_hidden

        permission(:layer_and_below_full)
          .may(:create, :create_in_subgroup, :update, :destroy)
          .in_same_layer_or_visible_below
      end
    end

    def in_same_group_or_hidden
      in_same_group || hidden_group
    end

    def in_same_group_or_below_or_hidden
      in_same_group_or_below || hidden_group
    end

    def in_same_layer_or_hidden
      in_same_layer || hidden_group
    end

    def in_same_layer_or_visible_below_or_hidden
      in_same_layer_or_visible_below || hidden_group
    end

    def hidden_group
      group.parent_id == ::Group::Verein.hidden.id
    end
  end
end
