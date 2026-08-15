# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::RoleDecorator
  def for_aside
    formatted_name_with_instrument(strong: true, show_end_on: true, show_start_on: true)
  end

  def for_history
    formatted_name_with_instrument
  end

  private

  def formatted_name_with_instrument(strong: false, show_end_on: false, show_start_on: false)
    role_name = model.to_s(:short)
    name = strong ? content_tag(:strong, role_name) : role_name
    suffix = instrument_or_label_suffix
    name = safe_join([name, FormatHelper::EMPTY_STRING, "(#{suffix})"]) if suffix.present?
    name = future_role_details(name, show_start_on)
    name = end_on_details(name, show_end_on)
    terminated_details(name)
  end

  def instrument_or_label_suffix
    if model.respond_to?(:instrument) && model.instrument.present?
      model.instrument_label
    elsif model.label.present?
      model.label
    end
  end
end
