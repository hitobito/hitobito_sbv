#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Event::GroupParticipation < ActiveRecord::Base
  require_dependency 'aasm'
  include ::AASM

  MUSIC_CLASSIFICATIONS = [
    {
      style: "Konzertmusik",
      types: {
        "Harmonie" => [
            "Höchstklasse",
            "1. Klasse",
            "2. Klasse",
            "3. Klasse",
            "4. Klasse"
      ],
      }}

        # Brass Band
        #     Höchstklasse
        #     "1. Klasse"
        #     "2. Klasse"
        #     "3. Klasse"
        #     "4. Klasse"
        # Fanfare Benelux Harmonie
        #     "1. Klasse"
        #     "2. Klasse"
        #     "3. Klasse"
        # Fanfare Benelux Brass Band
        #     "1. Klasse"
        #     "2. Klasse"
        #     "3. Klasse"
        # Fanfare mixte Harmonie
        #     "4. Klasse"
        # Fanfare mixte Brass Band
        #     "4. Klasse"

    # Unterhaltungsmusik
        # Harmonie
        #     Oberstufe
        #     Mittelstufe
        #     Unterstufe
        # Brass Band
        #     Oberstufe
        #     Mittelstufe
        #     Unterstufe

    # Parademusik
        # traditionelle Parademusik
        # Parademusik mit Evolution und Showparade
  ].freeze

  self.demodulized_route_keys = true

  ### ASSOCIATIONS

  belongs_to :event
  belongs_to :group

  ### VALIDATIONS

  validates_by_schema
  validates :group_id, uniqueness: { scope: :event_id }

  aasm column: 'state' do
    state :initial, initial: true
    state :music_style_selected
    state :music_type_and_level_selected
    state :completed

    event :select_music_style do
      transitions from: :initial, to: :music_style_selected
      transitions from: :music_type_and_level_selected, to: :music_style_selected
    end

    event :select_music_type do
      transitions from: :music_style_selected, to: :music_type_and_level_selected
    end
  end
end
