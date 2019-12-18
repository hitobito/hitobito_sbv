#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Event::GroupParticipation < ActiveRecord::Base
  require_dependency 'aasm'
  include ::AASM

  MUSIC_TYPES = %w[Type\ 1 Type\ 2 Type\ 3].freeze
  MUSIC_LEVELS = %w[Level\ 1 Level\ 2 Level\ 3].freeze

  self.demodulized_route_keys = true

  ### ASSOCIATIONS

  belongs_to :event
  belongs_to :group

  ### VALIDATIONS

  validates_by_schema
  validates :group_id, uniqueness: { scope: :event_id }

  aasm column: 'state' do
    state :initial, initial: true
    state :music_type_selected
    state :music_level_selected
    state :completed

    event :select_music_type do
      transition from :initial, to: :music_type_selected
      transition from :music_level_selected, to: :music_type_selected
    end

    event :select_music_level do
      transition from :music_type_selected, to: :music_level_selected
    end
  end
end
