# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

# this is used by Export::Tabular::GroupParticipations::Row as well
module GroupParticipationsFormatHelper
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

  def format_preferred_play_day_1(entry)
    day_name(entry.preferred_play_day_1)
  end

  def format_preferred_play_day_2(entry)
    day_name(entry.preferred_play_day_2)
  end

  private

  def group_participation_scope
    model_key = Event::GroupParticipation.name.underscore
    { scope: "activerecord.attributes.#{model_key}" }
  end

  def music_i18n_option(kind, value)
    [
      I18n.t("#{kind.to_s.pluralize}.#{value}", group_participation_scope),
      value
    ]
  end

  def day_name(value)
    return '' unless value

    I18n.t('date.day_names').fetch(value)
  end
end
