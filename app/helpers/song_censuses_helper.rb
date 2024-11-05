# frozen_string_literal: true

#  Copyright (c) 2020-2022, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module SongCensusesHelper
  def census_submitted_ratio(verband, total)
    census_submitted = total[verband.id].to_a.size
    census_total = verband.descendants.without_deleted.where(type: Group::Verein.sti_name).size

    # return t('.census_complete') if census_submitted == census_total
    t(".censuses_submitted", submitted: census_submitted, total: census_total)
  end

  def census_finish_button(census, group_id)
    if census.try(:current?) && census.finished?
      action_button(
        t("song_censuses.finish.submit"),
        new_group_song_census_path(group_id),
        :ok,
        data: {confirm: t("song_censuses.finish.start_new_census")}
      )
    end
  end

  def census_submit_button(concerts, group)
    if concerts.none?
      inactive_census_submit("none")
    elsif concerts.all?(&:song_census)
      inactive_census_submit("submitted")
    else
      active_census_submit("submit", submit_group_concerts_path(group))
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
    content_tag(:div, class: "tooltip-wrapper", title: census_submit_tooltip(key)) do
      action_button(census_submit_label(key), "#", nil, class: "disabled")
    end
  end
end
