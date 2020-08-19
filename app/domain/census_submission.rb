# frozen_string_literal: true
#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

# A SongCount counts as submitted to a census if a SongCensus is linked to it
class CensusSubmission
  def initialize(group, census)
    @group = group
    @census = census
  end

  def submit
    changed_rows = attach_concerts_to_census
    changed_rows > 0
  end

  private

  def attach_concerts_to_census
    Concert
      .where(verein: @group, song_census: nil)
      .update_all(song_census_id: @census.id) # rubocop:disable Rails/SkipsModelValidations
  end
end
