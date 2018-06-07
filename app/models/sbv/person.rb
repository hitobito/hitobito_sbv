# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Person
  extend ActiveSupport::Concern

  included do
    Person::PUBLIC_ATTRS << :correspondence_language

    # validates :correspondence_language,
    #           inclusion: { in: lambda do |_|
    #                              Settings.application.languages.to_hash.keys.collect(&:to_s)
    #                            end,
    #                        allow_blank: true }

  end

end
