#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

# == Schema Information
#
# Table name: event_group_participations
#
#  id                             :integer          not null, primary key
#  primary_state                  :string(255)      not null
#  event_id                       :integer          not null
#  group_id                       :integer          not null
#  music_style                    :string(255)
#  music_type                     :string(255)
#  music_level                    :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  preferred_play_day_1           :integer
#  preferred_play_day_2           :integer
#  terms_accepted                 :boolean          default(FALSE), not null
#  parade_music                   :string(255)
#  joint_participation            :boolean          default(FALSE), not null
#  secondary_state                :string(255)      not null
#  secondary_group_id             :integer
#  secondary_group_terms_accepted :boolean          default(FALSE), not null
#

class Event::GroupParticipation < ActiveRecord::Base
  include ::AASM

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

  # these two constants should, if they ever need to change, be made
  # configurable through additional attributes or a relation on Event::Date
  # This duplication in structure with the MUSIC_CLASSIFICATIONS is actually a
  # dependency.
  AVAILABLE_PLAY_DAYS = { thursday: 4, friday: 5, saturday: 6, sunday: 0 }.freeze
  MUSIC_LEVEL_PLAY_DAYS = {
    'concert_music' => {
      'harmony' => {
        'highest' => AVAILABLE_PLAY_DAYS.values_at(:friday, :saturday, :sunday),
        'first'   => AVAILABLE_PLAY_DAYS.values,
        'second'  => AVAILABLE_PLAY_DAYS.values,
        'third'   => AVAILABLE_PLAY_DAYS.values,
        'fourth'  => AVAILABLE_PLAY_DAYS.values_at(:sunday)
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

  ### ATTRIBUTES

  attr_accessor :secondary_group_is_primary

  ### ASSOCIATIONS

  belongs_to :event, class_name: 'Event::Festival'
  belongs_to :group
  belongs_to :secondary_group, class_name: 'Group'

  ### VALIDATIONS

  validates_by_schema
  validates :group_id, uniqueness: { scope: :event_id }
  # validates_with ParticipantValidator (every group may only apply once per
  # event, but can be primary or secondary)
  validates_with PreferredDateValidator

  ### STATE MACHINES

  aasm :primary, column: 'primary_state', namespace: :primary do # rubocop:disable Metrics/BlockLength
    state :opened, initial: true
    state :joint_participation_selected
    state :primary_group_selected
    state :music_style_selected
    state :music_type_and_level_selected
    state :preferred_play_day_selected
    state :terms_accepted
    state :completed

    event :progress, guard: :application_possible? do
      transitions from: :opened,                        to: :joint_participation_selected,
                  guard: :joint_participation?
      transitions from: :joint_participation_selected,  to: :primary_group_selected,
                  after: :store_groups_correctly
      transitions from: :opened,                        to: :primary_group_selected

      transitions from: :primary_group_selected,        to: :music_style_selected
      transitions from: :music_style_selected,          to: :music_type_and_level_selected
      transitions from: :music_type_and_level_selected, to: :preferred_play_day_selected
      transitions from: :preferred_play_day_selected,   to: :terms_accepted
      transitions from: :terms_accepted,                to: :completed
    end

    event :edit_participation, guard: :application_possible? do
      transitions from: [
        :joint_participation_selected,
        :primary_group_selected,
        :music_style_selected,
        :music_type_and_level_selected,
        :preferred_play_day_selected,
        :terms_accepted,
        :completed
      ], to: :opened, after: :clean_joining_groups
    end

    event :edit_joining_group, guard: :application_possible? do
      transitions from: [
        :music_style_selected,
        :music_type_and_level_selected,
        :preferred_play_day_selected,
        :terms_accepted,
        :completed
      ], to: :joint_participation_selected, after: :clean_joining_groups
    end

    event :edit_music_style, guard: :application_possible? do
      transitions from: [
        :music_type_and_level_selected,
        :preferred_play_day_selected,
        :terms_accepted,
        :completed
      ], to: :primary_group_selected, after: :clean_music_style
    end

    event :edit_music_type_and_level, guard: :application_possible? do
      transitions from: [
        :preferred_play_day_selected,
        :terms_accepted,
        :completed
      ], to: :music_style_selected, after: :clean_music_type_and_level
    end

    event :edit_date_preference, guard: :application_possible? do
      transitions from: [
        :terms_accepted,
        :completed
      ], to: :music_type_and_level_selected, after: :clean_date_preference
    end
  end

  aasm :secondary, column: 'secondary_state', namespace: :secondary do
    state :not_present, initial: true
    state :opened
    state :terms_accepted
    state :completed

    event :join, guard: :application_possible? do
      transitions from: :not_present,    to: :opened
    end

    event :progress, guard: :application_possible? do
      transitions from: :not_present,    to: :opened
      transitions from: :opened,         to: :terms_accepted
      transitions from: :terms_accepted, to: :completed
    end
  end

  ### INSTANCE METHODS

  def to_s
    "#{group} -> #{event}"
  end

  def possible_day_numbers
    MUSIC_LEVEL_PLAY_DAYS
      .fetch(music_style, {})
      .fetch(music_type, {})
      .fetch(music_level, {})
  end

  def progress_for(participating_group)
    send(:"progress_#{state_machine_for(participating_group)}!") # e.g. progress_primary!
  end

  def state_for(participating_group)
    ActiveSupport::StringInquirer.new(
      aasm(
        state_machine_for(participating_group) # :primary or :secondary
      ).current_state.to_s # e.g. terms_accepted
    )
  end

  def primary_or_only?(participating_group)
    !joint_participation || state_machine_for(participating_group) == :primary
  end

  private

  def state_machine_for(participating_group = nil)
    case participating_group
    when group           then :primary
    when secondary_group then :secondary
    else
      raise 'Group not related to this participation'
    end
  end

  # after-transition HOOKS, happening after the transition, but before save

  def store_groups_correctly
    join_secondary

    if secondary_group_is_primary == 'true'
      self.group_id, self.secondary_group_id = secondary_group_id, group_id
    end
  end

  def clean_date_preference
    self.preferred_play_day_1 = nil
    self.preferred_play_day_2 = nil

    true
  end

  def clean_music_type_and_level
    self.music_type = nil
    self.music_level = nil

    clean_date_preference
  end

  def clean_music_style
    self.music_style = nil

    clean_music_type_and_level
  end

  def clean_joining_groups
    self.joint_participation = false
    self.secondary_state = :not_present
    self.secondary_group_id = nil
    self.secondary_group_terms_accepted = false

    clean_music_style
  end

  # GUARDS

  def application_possible?
    event.application_possible?
  end
end
