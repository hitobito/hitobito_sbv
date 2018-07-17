#  Copyright (c) 2018, Schweizer Blasmusikverband. This file is part of
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
    move_unsubmitted_song_counts_to_new_period
    lock_submitted_song_counts
  end

  private

  def finish_previous_song_census
    @old.touch(:finish_at)
  end

  def move_unsubmitted_song_counts_to_new_period
    SongCount.where(song_census: nil).update_all("year = #{@new.year.to_i}")
  end

  def lock_submitted_song_counts
    @old.song_counts.update_all('editable = false')
  end

end
