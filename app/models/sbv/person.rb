# frozen_string_literal: true

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Person
  extend ActiveSupport::Concern

  included do
    include Person::ActiveYears

    Person::PUBLIC_ATTRS << :correspondence_language << :personal_data_usage

    validates :first_name, :last_name, :birthday, :correspondence_language, presence: true

    validates :correspondence_language, inclusion: {
      in: Settings.application.correspondence_languages.to_h.keys.map(&:to_s)
    }

  end
end
