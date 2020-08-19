# frozen_string_literal: true

#  Copyright (c) 2018-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class VeteranYears

  attr_reader :start_year, :end_year, :passive_years

  def initialize(start_year, end_year, passive_years = [])
    @start_year    = start_year
    @end_year      = end_year
    @passive_years = passive_years
  end

  def years
    past_years + current_year
  end

  def <=>(other)
    @start_year <=> other.start_year
  end

  def +(other)
    new_start   = [@start_year, other.start_year].min
    new_end     = [@end_year, other.end_year].max
    new_passive = (new_start..new_end).to_a - (year_list + other.year_list)

    self.class.new(new_start, new_end, new_passive)
  end

  protected

  def year_list
    (@start_year..@end_year).to_a - @passive_years
  end

  private

  def passive_and_starting_years
    @passive_years.map { |y| [y, y.succ] }.flatten.uniq
  end

  def past_years
    @end_year - @start_year - passive_and_starting_years.size
  end

  def current_year
    Date.current.year == @end_year ? 1 : 0
  end

end
