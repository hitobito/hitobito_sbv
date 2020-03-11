# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module SongCensusesHelper
  def census_finish_button(census, group_id)
    if census.try(:current?) && census.finished?
      action_button(
        t('song_censuses.finish.submit'),
        new_group_song_census_path(group_id),
        :ok,
        data: { confirm: t('song_censuses.finish.start_new_census') }
      )
    end
  end
end
