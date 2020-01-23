#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module GroupParticipationsHelper
  def music_styles_selection
    Event::GroupParticipation::MUSIC_CLASSIFICATIONS.map do |h|
      next if h[:style] == 'parade_music'
      music_i18n_option(:music_style, h[:style])
    end.compact
  end

  def music_types_selection_for(music_style)
    music_types_for(music_style).keys.map { |v| music_i18n_option(:music_type, v) }
  end

  def music_level_selections_for(music_style)
    music_types_for(music_style).map do |type, levels|
      values = levels.map { |level| music_i18n_option(:music_level, level) }

      content_tag(:div, hidden: true, class: type) { options_for_select(values || []) }
    end.join.html_safe # rubocop:disable Rails/OutputSafety contains no external input
  end

  def music_types_for(music_style)
    Event::GroupParticipation::MUSIC_CLASSIFICATIONS.find { |h| h[:style] == music_style }[:types]
  end

  def music_i18n_option(kind, value)
    [
      t("#{kind.to_s.pluralize}.#{value}", group_participation_scope),
      value
    ]
  end

  def group_participation_scope
    model_key = Event::GroupParticipation.name.underscore
    { scope: "activerecord.attributes.#{model_key}" }
  end

  def format_music_style(entry)
    music_i18n_option(:music_style, entry.music_style).first
  end

  def format_music_type(entry)
    music_i18n_option(:music_type, entry.music_type).first
  end

  def format_parade_music(entry)
    music_i18n_option(:music_type, entry.parade_music).first
  end

  def format_music_level(entry)
    music_i18n_option(:music_level, entry.music_level).first
  end

  def format_event_group_participation_title(entry)
    t(:name, event: entry.event.to_s, group: entry.group.to_s,
             scope: 'activerecord.attributes.event/group_participation')
  end

  def format_preferred_play_day_1(entry)
    day_name(entry.preferred_play_day_1)
  end

  def format_preferred_play_day_2(entry)
    day_name(entry.preferred_play_day_2)
  end

  def play_day_selection_for(record)
    day_numbers = record.possible_day_numbers
    day_names   = t('date.day_names').values_at(*day_numbers)

    day_names.zip(day_numbers)
  end

  def group_participation_edit_link(stage, participating_group_id)
    content_tag :p do
      link_to t("events.group_participations.edit_stages.#{stage}"),
              action: 'edit_stage',
              participating_group: participating_group_id,
              edit_stage: stage
    end
  end

  def link_to_terms
    link_to t(:terms, group_participation_scope),
            t(:terms_url, group_participation_scope),
            target: '_blank'
  end

  private

  def day_name(value)
    return '' unless value
    t('date.day_names').fetch(value)
  end
end
