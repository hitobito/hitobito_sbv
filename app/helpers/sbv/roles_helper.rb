# frozen_string_literal: true

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::RolesHelper
  def group_options
    @group_selection.map do |group| # rubocop:disable Rails/HelperInstanceVariable
      [group.to_s, group.id]
    end
  end

  def default_language_for_person(group)
    group.language
  end

  def role_type_class(entry, group = nil)
    if entry.type.present?
      entry.type.constantize
    elsif @type.present?
      @type
    elsif group&.standard_role
      group.standard_role
    else
      entry.class
    end
  end

  def mitglied_role_type?(role_type)
    role_type.present? && role_type <= Role::MitgliederMitglied
  end

  private

  def supported_languages
    Settings.application.languages
      .to_hash
      .merge(Settings.application.additional_languages&.to_hash || {})
      .invert
  end
end
