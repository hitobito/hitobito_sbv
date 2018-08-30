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
      end
    end
  end
end
