# frozen_string_literal: true

#  Copyright (c) 2019-2024, Schweizer Blasmusikverband. This file is part of
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
  include Event::GroupParticipationData

  self.demodulized_route_keys = true

  ### ATTRIBUTES

  attr_accessor :secondary_group_is_primary

  ### ASSOCIATIONS

  belongs_to :event, class_name: "Event::Festival"
  belongs_to :group
  belongs_to :secondary_group, class_name: "Group"

  ### VALIDATIONS

  validates_by_schema

  validates :group_id, uniqueness: {scope: :event_id}
  # validates_with ParticipantValidator (every group may only
  # apply once per event, but can be primary or secondary)

  validates :secondary_group_id, presence: {if: proc do |gp|
    (gp.primary_primary_group_selected? && gp.joint_participation) ||
      gp.secondary_group_id_change
  end}

  validates :music_style, presence: {if: :primary_music_style_selected?}
  validates :music_type, presence: {if: :primary_music_type_and_level_selected?}
  validates :music_level, presence: {if: :primary_music_type_and_level_selected?}
  validates :parade_music, presence: {if: :primary_parade_music_selected?}

  ### STATE MACHINES

  # rubocop:disable Layout/LineLength,Layout/ExtraSpacing
  aasm :primary, column: "primary_state", namespace: :primary do # rubocop:disable Metrics/BlockLength
    state :opened, initial: true
    state :joint_participation_selected
    state :primary_group_selected
    state :music_style_selected
    state :music_type_and_level_selected
    state :parade_music_selected

    event :progress, guard: :application_possible? do
      transitions from: :opened,                        to: :joint_participation_selected,  guard: :joint_participation?
      transitions from: :joint_participation_selected,  to: :primary_group_selected,                                  after: :store_groups_correctly
      transitions from: :opened,                        to: :primary_group_selected

      transitions from: :primary_group_selected,        to: :music_style_selected
      transitions from: :music_style_selected,          to: :music_type_and_level_selected
      transitions from: :music_type_and_level_selected, to: :parade_music_selected
    end

    event :edit_participation, guard: :application_possible? do
      transitions from: [
        :joint_participation_selected,
        :primary_group_selected,
        :music_style_selected,
        :music_type_and_level_selected,
        :parade_music_selected
      ], to: :opened, after: :clean_joining_groups
    end

    event :edit_joining_group, guard: :application_possible? do
      transitions from: [
        :primary_group_selected,
        :music_style_selected,
        :music_type_and_level_selected,
        :parade_music_selected
      ], to: :joint_participation_selected, after: :clean_joining_groups
    end

    event :edit_music_style, guard: :application_possible? do
      transitions from: [
        :music_style_selected,
        :music_type_and_level_selected,
        :parade_music_selected
      ], to: :primary_group_selected, after: :clean_music_style
    end

    event :edit_music_type_and_level, guard: :application_possible? do
      transitions from: [
        :music_type_and_level_selected,
        :parade_music_selected
      ], to: :music_style_selected, after: :clean_music_type_and_level
    end

    event :edit_parade_music, guard: :application_possible? do
      transitions from: [
        :parade_music_selected
      ], to: :music_type_and_level_selected, after: :clean_parade_music
    end
  end

  aasm :secondary, column: "secondary_state", namespace: :secondary do
    state :not_present, initial: true
    state :opened

    event :join, guard: :application_possible? do
      transitions from: :not_present,    to: :opened
    end

    event :progress, guard: :application_possible? do
      transitions from: :not_present,    to: :opened
    end
  end
  # rubocop:enable Layout/LineLength,Layout/ExtraSpacing

  ### INSTANCE METHODS

  def to_s
    "#{group} -> #{event}"
  end

  def required_attrs
    %i[
      joint_participation
      secondary_group
      music_style
      music_type
      music_level
      parade_music
    ]
  end

  def progress_for(participating_group)
    send(:"progress_#{state_machine_for(participating_group)}") # e.g. progress_primary
  end

  def state_for(participating_group)
    ActiveSupport::StringInquirer.new(
      aasm(
        state_machine_for(participating_group) # :primary or :secondary
      ).current_state.to_s # e.g. music_style_selected
    )
  end

  def primary_or_only?(participating_group)
    !joint_participation || state_machine_for(participating_group) == :primary
  end

  def completed?(participating_group)
    state_machine = aasm(state_machine_for(participating_group))

    states = state_machine.states.map(&:name)
    current = state_machine.current_state

    (states.last == current)
  end

  def rollback_state_if_invalid(saved)
    restore_attributes(%w[primary_state secondary_state]) unless saved
  end

  private

  def state_machine_for(participating_group = nil)
    case participating_group.layer_group
    when group then :primary
    when secondary_group then :secondary
    else
      raise "Group not related to this participation"
    end
  end

  # after-transition HOOKS, happening after the transition, but before save

  def store_groups_correctly
    join_secondary

    if %w[true 1].include?(secondary_group_is_primary)
      self.group_id, self.secondary_group_id = secondary_group_id, group_id
    end
  end

  def clean_parade_music
    self.parade_music = nil

    true
  end

  # def clean_date_preference
  #   self.preferred_play_day_1 = nil
  #   self.preferred_play_day_2 = nil
  #
  #   true
  # end

  def clean_music_type_and_level
    self.music_type = nil
    self.music_level = nil

    # clean_date_preference
    true
  end

  def clean_music_style
    self.music_style = nil

    clean_music_type_and_level
  end

  def clean_joining_groups
    self.joint_participation = false
    self.secondary_state = :not_present
    self.secondary_group_id = nil

    clean_music_style
  end

  # GUARDS

  def application_possible?
    event.application_possible?
  end
end
