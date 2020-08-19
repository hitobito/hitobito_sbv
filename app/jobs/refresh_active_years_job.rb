# frozen_string_literal: true
class RefreshActiveYearsJob < RecurringJob

  def perform
    Person.find_each do |person|
      person.cache_active_years
      person.save(validate: false)
    end
  end

  private

  def next_run
    Time.new(Time.zone.now.year.succ, 1, 1, 5, 0).in_time_zone
  end

end
