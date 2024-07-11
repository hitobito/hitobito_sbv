# frozen_string_literal: true

#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

# == Schema Information
#
# Table name: events
#
#  id                          :integer          not null, primary key
#  type                        :string(255)
#  name                        :string(255)      not null
#  number                      :string(255)
#  motto                       :string(255)
#  cost                        :string(255)
#  maximum_participants        :integer
#  contact_id                  :integer
#  description                 :text(65535)
#  location                    :text(65535)
#  application_opening_at      :date
#  application_closing_at      :date
#  application_conditions      :text(65535)
#  kind_id                     :integer
#  state                       :string(60)
#  priorization                :boolean          default(FALSE), not null
#  requires_approval           :boolean          default(FALSE), not null
#  created_at                  :datetime
#  updated_at                  :datetime
#  participant_count           :integer          default(0)
#  application_contact_id      :integer
#  external_applications       :boolean          default(FALSE)
#  applicant_count             :integer          default(0)
#  teamer_count                :integer          default(0)
#  signature                   :boolean
#  signature_confirmation      :boolean
#  signature_confirmation_text :string(255)
#  creator_id                  :integer
#  updater_id                  :integer
#  applications_cancelable     :boolean          default(FALSE), not null
#  required_contact_attrs      :text(65535)
#  hidden_contact_attrs        :text(65535)
#  display_booking_info        :boolean          default(TRUE), not null
#

# A festival ("Musikfest") is an event which whole groups apply to. The
# application is more complicated because the groups can play together
# and compete in different levels and disciplines.
class Event::Festival < Event
  self.used_attributes -= [
    :application_conditions,
    :applications_cancelable,
    :cost,
    :external_applications,
    :maximum_participants,
    :motto,
    :signature,
    :signature_confirmation,
    :signature_confirmation_text
  ]

  def participant_types
    [] # this disables the selection of required person-attributes
  end

  def supports_application_details?
    true
  end

  # OPTIMIZE: this could be persisted in the applicant_count-column upon
  #           submitting the participation.
  #           Open question: on which state-change should this happen?
  #           Relevant API: Event::Participatable#refresh_participant_counts!
  def applicant_count
    group_participations.count
  end

  ### ASSOCIATIONS

  has_many :group_participations, foreign_key: "event_id",
    dependent: :destroy,
    inverse_of: :event

  class << self
    def participatable(group)
      (
        Set.new(application_possible) -
        Set.new(upcoming.participation_by(group))
      ).to_a
    end

    def participation_by(group)
      group_fields = [
        "event_group_participations.group_id = ?",
        "event_group_participations.secondary_group_id = ?"
      ].join(" OR ")

      joins(:group_participations).where([group_fields, group.id, group.id])
    end
  end
end
