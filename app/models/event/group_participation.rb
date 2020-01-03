#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require_dependency 'aasm'

class Event::GroupParticipation < ActiveRecord::Base
  include ::AASM

  AVAILABLE_PLAY_DAYS = { thursday: 4, friday: 5, saturday: 6, sunday: 0 }.freeze

  enum preferred_play_day_1: AVAILABLE_PLAY_DAYS, _prefix: :play_day_1
  enum preferred_play_day_2: AVAILABLE_PLAY_DAYS, _prefix: :play_day_2

  MUSIC_CLASSIFICATIONS = [
    {
      style: 'concert_music',
      types: {
        'harmony'                    => %w(highest first second third fourth),
        'brass_band'                 => %w(highest first second third fourth),
        'fanfare_benelux_harmony'    => %w(first second third),
        'fanfare_benelux_brass_band' => %w(first second third),
        'fanfare_mixte_harmony'      => %w(fourth),
        'fanfare_mixte_brass_band'   => %w(fourth)
      }
    },
    {
      style: 'contemporary_music',
      types: {
        'harmony'    => %w(high medium low),
        'brass_band' => %w(high medium low)
      }
    },
    {
      style: 'parade_music',
      types: {
        'traditional_parade' => %w(),
        'show_parade'        => %w()
      }
    }
  ].freeze

  MUSIC_LEVEL_PLAY_DAYS = {
    'concert_music' => {
      'harmony' => {
        'highest' => AVAILABLE_PLAY_DAYS.values_at(:friday, :saturday, :sunday),
        'first'   => AVAILABLE_PLAY_DAYS.values,
        'second'  => AVAILABLE_PLAY_DAYS.values,
        'third'   => AVAILABLE_PLAY_DAYS.values,
        'fourth'  => [AVAILABLE_PLAY_DAYS[:sunday]]
      },
      'brass_band' => {
        'highest' => AVAILABLE_PLAY_DAYS.values_at(:thursday, :friday),
        'first'   => AVAILABLE_PLAY_DAYS.values,
        'second'  => AVAILABLE_PLAY_DAYS.values,
        'third'   => AVAILABLE_PLAY_DAYS.values,
        'fourth'  => AVAILABLE_PLAY_DAYS.values_at(:thursday)
      },
      'fanfare_benelux_harmony' => {
        'first'  => AVAILABLE_PLAY_DAYS.values_at(:thursday),
        'second' => AVAILABLE_PLAY_DAYS.values_at(:thursday),
        'third'  => AVAILABLE_PLAY_DAYS.values_at(:thursday, :friday)
      },
      'fanfare_benelux_brass_band' => {
        'first'  => AVAILABLE_PLAY_DAYS.values_at(:thursday),
        'second' => AVAILABLE_PLAY_DAYS.values_at(:thursday),
        'third'  => AVAILABLE_PLAY_DAYS.values_at(:thursday, :friday)
      },
      'fanfare_mixte_harmony' => {
        'fourth' => AVAILABLE_PLAY_DAYS.values_at(:thursday)
      },
      'fanfare_mixte_brass_band' => {
        'fourth' => AVAILABLE_PLAY_DAYS.values_at(:thursday)
      }
    },
    'contemporary_music' => {
      'harmony' => {
        'high'   => AVAILABLE_PLAY_DAYS.values_at(:saturday),
        'medium' => AVAILABLE_PLAY_DAYS.values_at(:saturday, :sunday),
        'low'    => AVAILABLE_PLAY_DAYS.values_at(:thursday)
      },
      'brass_band' => {
        'high'   => AVAILABLE_PLAY_DAYS.values_at(:sunday),
        'medium' => AVAILABLE_PLAY_DAYS.values_at(:saturday),
        'low'    => AVAILABLE_PLAY_DAYS.values_at(:friday)
      }
    },
    'parade_music' => {}
  }.freeze

  self.demodulized_route_keys = true

  ### ASSOCIATIONS

  belongs_to :event, class_name: 'Event::Festival'
  belongs_to :group

  ### VALIDATIONS

  validates_by_schema
  validates :group_id, uniqueness: { scope: :event_id }
  validate :preferred_play_days_are_valid

  def preferred_play_days_are_valid
    errors.delete(:preferred_play_day_1)
    errors.delete(:preferred_play_day_2)

    return true unless music_style.present? && music_type.present? && music_level.present?

    one_play_day_is_selected
    preferred_play_days_are_possible
    preferred_play_days_are_separate
  end

  def one_play_day_is_selected
    if preferred_play_day_1.blank? && preferred_play_day_2.blank?
      errors[:base] = :one_needs_to_be_selected
    end
  end

  def preferred_play_days_are_separate
    if preferred_play_day_1 == preferred_play_day_2
      errors[:preferred_play_day_2] = :duplicate
    end
  end

  def preferred_play_days_are_possible
    days = MUSIC_LEVEL_PLAY_DAYS.fetch(music_style, {})
                                .fetch(music_type, {})
                                .fetch(music_level, {})

    [:preferred_play_day_1, :preferred_play_day_2].each do |day|
      if send(day) && (day_number = AVAILABLE_PLAY_DAYS[day]) && !days.include?(day_number)
        errors[day] = :impossible
      end
    end
  end

  ### STATE MACHINE

  aasm column: 'state' do
    state :initial, initial: true
    state :music_style_selected
    state :music_type_and_level_selected
    state :preferred_play_day_selected
    state :completed


    event :progress_in_application do
      transitions from: :initial,                       to: :music_style_selected
      transitions from: :music_style_selected,          to: :music_type_and_level_selected
      transitions from: :music_type_and_level_selected, to: :preferred_play_day_selected
      transitions from: :preferred_play_day_selected,   to: :completed
    end

    event :select_music_style do
      transitions from: :initial,                       to: :music_style_selected
      transitions from: :music_type_and_level_selected, to: :music_style_selected
    end

    event :select_music_type do
      transitions from: :music_style_selected,          to: :music_type_and_level_selected
    end

    event :select_preferred_play_day do
      transitions from: :music_type_and_level_selected, to: :preferred_play_day_selected
    end
  end

  ### INSTANCE METHODS

  def to_s
    "#{group} -> #{event}"
  end
end
