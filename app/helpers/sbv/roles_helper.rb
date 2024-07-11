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
    return supported_languages.first if group.correspondence_language.nil?

    group.correspondence_language
  end

  private

  def supported_languages
    Settings.application.correspondence_languages.to_hash.invert
  end
end
