# frozen_string_literal: true

#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::GroupAbility
  extend ActiveSupport::Concern

  included do
    on(Group) do
      permission(:any).may(:"index_event/festivals").all
      permission(:any).may(:query).all
      permission(:any).may(:deleted_subgroups).if_writable
      permission(:festival_participation).may(:manage_festival_application).in_same_layer

      permission(:group_full).may(:create_history_member).in_same_group
      permission(:group_and_below_full).may(:create_history_member).in_same_group_or_below
      permission(:layer_full).may(:create_history_member).in_same_layer
      permission(:layer_and_below_full).may(:create_history_member).in_same_layer_or_below

      permission(:uv_lohnsumme).may(:show_uv_lohnsummen).everywhere_if_admin
      permission(:uv_lohnsumme).may(:edit_uv_lohnsummen).everywhere_if_admin_or_in_same_layer

      permission(:finance).may(:subverein_select).in_layer_group
    end
  end

  def if_writable
    [
      :layer_and_below_full,
      :layer_full,
      :group_and_below_full,
      :group_full
    ].any? do |permission|
      user_context.permission_group_ids(permission).include?(group.id)
    end
  end

  def everywhere_if_admin
    [
      Group::Generalverband::Admin,
      Group::Root::Admin,
      Group::Mitgliederverband::Admin
      # Group::Regionalverband::Admin # is not allowed, according to hitobito/hitobito_sbv#30
    ].any? { |admin_role| role_type?(admin_role) }
  end

  def everywhere_if_admin_or_in_same_layer
    everywhere_if_admin || in_same_layer
  end
end
