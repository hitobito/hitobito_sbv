# frozen_string_literal: true

#  Copyright (c) 2018-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

# rubocop:disable Rails/SkipsModelValidations if this makes a census or count invalid, it reflects an invalid reality...
class CensusPeriodSwitch

  def initialize(old, new)
    @old = old
    @new = new
  end

  def perform
    finish_previous_song_census
    move_unsubmitted_concerts_to_new_period
    lock_submitted_concerts
    correct_concert_year_to_match_period
  end

  # def revert
  #   # unlock submitted concerts
  #   @old.concerts.update_all('editable = true')
  #   # move all concerts from new census to old
  #   @new.concerts.update_all("song_census_id = #{@old.id}")
  #   # adjust period of unsubmitted concerts and concerts in old period
  #   Concert.where(song_census: [nil, @old]).update_all("year = '#{@old.year.to_i}'")
  #   # delete new song_census
  #   @new.destroy
  # end

  private

  def finish_previous_song_census
    @old.touch(:finish_at)
  end

  def move_unsubmitted_concerts_to_new_period
    Concert.where(song_census: nil).update_all("year = #{@new.year.to_i}")
  end

  def lock_submitted_concerts
    @old.concerts.update_all('editable = false')
  end

  def correct_concert_year_to_match_period
    @old.concerts.update_all("year = #{@old.year.to_i}")
  end

end
