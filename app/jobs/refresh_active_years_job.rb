# frozen_string_literal: true

#  Copyright (c) 2019-2021, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class RefreshActiveYearsJob < RecurringJob
  private

  def perform_internal
    Person.find_each do |person|
      person.cache_active_years
      person.save(validate: false)
    end
  end

  def next_run
    Time.new(Time.zone.now.year.succ, 1, 1, 5, 0).in_time_zone
  end
end
