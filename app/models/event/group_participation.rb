#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require_dependency 'aasm'

class Event::GroupParticipation < ActiveRecord::Base
  include ::AASM
  include I18nEnums

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

  # i18n_enum :music_styles, Event::GroupParticipation::MUSIC_CLASSIFICATIONS.map { |h| h[:style] }, key: :music_styles

  self.demodulized_route_keys = true

  ### ASSOCIATIONS

  belongs_to :event, class_name: 'Event::Festival'
  belongs_to :group

  ### VALIDATIONS

  validates_by_schema
  validates :group_id, uniqueness: { scope: :event_id }

  ### STATE MACHINE

  aasm column: 'state' do
    state :initial, initial: true
    state :music_style_selected
    state :music_type_and_level_selected
    state :completed


    event :progress_in_application do
      transitions from: :initial,                       to: :music_style_selected
      transitions from: :music_style_selected,          to: :music_type_and_level_selected
      transitions from: :music_type_and_level_selected, to: :completed
    end

    event :select_music_style do
      transitions from: :initial,                       to: :music_style_selected
      transitions from: :music_type_and_level_selected, to: :music_style_selected
    end

    event :select_music_type do
      transitions from: :music_style_selected,          to: :music_type_and_level_selected
    end
  end
end
