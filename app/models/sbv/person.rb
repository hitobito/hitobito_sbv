# frozen_string_literal: true

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Person
  extend ActiveSupport::Concern

  included do
    include Person::ActiveYears

    validates :first_name, :last_name, presence: true
  end

  def mitglied_role_in(group)
    return nil unless group

    group_ids = group.self_and_descendants.pluck(:id)
    roles.find { |role| role.is_a?(Role::MitgliederMitglied) && group_ids.include?(role.group_id) }
  end

  def instrument_for_group(group)
    mitglied_role_in(group)&.instrument_label
  end

  def instrument
    instrument_for_group(primary_group)
  end

  def mitglied_roles_with_instrument
    roles.select { |role| role.is_a?(Role::MitgliederMitglied) && role.instrument.present? }
  end
end
