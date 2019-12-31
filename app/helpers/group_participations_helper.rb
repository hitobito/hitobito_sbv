#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module GroupParticipationsHelper
  def music_styles_selection
    Event::GroupParticipation::MUSIC_CLASSIFICATIONS.map do |h|
      music_i18n_option(:music_style, h[:style])
    end
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
    model_key = Event::GroupParticipation.name.underscore
    [
      t("activerecord.attributes.#{model_key}.#{kind.to_s.pluralize}.#{value}"),
      value
    ]
  end

  def format_music_style(entry)
    music_i18n_option(:music_style, entry.music_style).first
  end

  def format_music_type(entry)
    music_i18n_option(:music_type, entry.music_type).first
  end

  def format_music_level(entry)
    music_i18n_option(:music_level, entry.music_level).first
  end

  def format_event_group_participation_title(entry)
    t(:name, event: entry.event.to_s, group: entry.group.to_s,
             scope: 'activerecord.attributes.event/group_participation')
  end
end
