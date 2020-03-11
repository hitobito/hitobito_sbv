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

  def census_submit_button(concerts, group)
    if concerts.none?
      inactive_census_submit('none')
    elsif concerts.all?(&:song_census)
      inactive_census_submit('submitted')
    else
      active_census_submit('submit', submit_group_concerts_path(group))
    end
  end

  private

  def census_submit_label(key)
    t("song_censuses.submit_button.label.#{key}")
  end

  def census_submit_tooltip(key)
    t("song_censuses.submit_button.tooltip.#{key}")
  end

  def active_census_submit(key, url)
    action_button(
      census_submit_label(key), url, nil,
      method: :post, title: census_submit_tooltip(key)
    )
  end

  def inactive_census_submit(key)
    action_button(
      census_submit_label(key), '#', nil,
      class: 'disabled', title: census_submit_tooltip(key)
    )
  end
end
