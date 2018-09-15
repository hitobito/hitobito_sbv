# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Person
  extend ActiveSupport::Concern

  included do
    Person::PUBLIC_ATTRS << :correspondence_language
    Person::FILTER_ATTRS += [:active_years, :prognostic_active_years]

    validates :first_name, :last_name, :birthday, presence: true

    # validates :correspondence_language,
    #           inclusion: { in: lambda do |_|
    #                              Settings.application.languages.to_hash.keys.collect(&:to_s)
    #                            end,
    #                        allow_blank: true }

  end

  def prognostic_active_years
    active_years(1.year.from_now)
  end

  def active_years(year = Time.zone.now)
    roles.with_deleted.where("type LIKE '%Mitglied'").map do |role|
      VeteranYears.new(role.created_at.year, (role.deleted_at || year).year)
    end.sort.sum.years.to_i
  end

end
