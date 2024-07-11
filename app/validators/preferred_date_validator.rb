# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or
#  at https://github.com/hitobito/hitobito_sbv.

class PreferredDateValidator < ActiveModel::Validator
  delegate :music_style, :music_type, :music_level,
    :preferred_play_day_1, :preferred_play_day_2,
    :errors, :changed,
    to: :record

  attr_reader :record

  def validate(record)
    @record = record

    return true if music_not_chosen?
    return true if date_reset?
    return true if date_unchanged?

    errors.delete(:preferred_play_day_1)
    errors.delete(:preferred_play_day_2)

    one_play_day_is_selected
    two_play_days_are_selected_if_possible
    preferred_play_days_are_possible
    preferred_play_days_are_separate
  end

  def music_not_chosen?
    music_chosen = music_style.present? &&
      music_type.present? &&
      music_level.present? &&
      !music_just_changed?

    !music_chosen
  end

  def music_just_changed?
    changed.include?("music_style") ||
      changed.include?("music_type") ||
      changed.include?("music_level")
  end

  def date_reset?
    date_changed? && date_empty?
  end

  def date_unchanged?
    !date_changed? && !date_empty?
  end

  def date_empty?
    preferred_play_day_1.nil? && preferred_play_day_2.nil?
  end

  def date_changed?
    changed.include?("preferred_play_day_1") || changed.include?("preferred_play_day_2")
  end

  def error_translation(attr, key)
    I18n.t(key, scope: "activerecord.errors.models." \
           "event/group_participation" \
           ".attributes.#{attr}")
  end

  def add_translated_error(attr, key)
    errors.add(attr, key, message: error_translation(attr, key))
  end

  def one_play_day_is_selected
    if preferred_play_day_1.blank? && preferred_play_day_2.blank?
      add_translated_error(:base, :date_preference_missing)
    end
  end

  def two_play_days_are_selected_if_possible
    if record.may_prefer_two_days?
      if preferred_play_day_1.blank? || preferred_play_day_2.blank?
        add_translated_error(:base, :date_preference_incomplete)
      end
    end
  end

  def preferred_play_days_are_separate
    if preferred_play_day_1 == preferred_play_day_2
      add_translated_error(:preferred_play_day_2, :duplicate)
    end
  end

  def preferred_play_days_are_possible
    days = record.possible_day_numbers

    [:preferred_play_day_1, :preferred_play_day_2].each do |day|
      day_number = record.send(day)

      if day_number && !days.include?(day_number)
        add_translated_error(day, :impossible)
      end
    end
  end
end
