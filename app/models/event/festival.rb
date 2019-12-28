#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'set'

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

  ### ASSOCIATIONS

  has_many :group_participations, foreign_key: 'event_id', dependent: :destroy

  class << self
    def participatable(group)
      (
        Set.new(application_possible) -
        Set.new(upcoming.participation_by(group))
      ).to_a
    end

    def participation_by(group)
      joins(:group_participations)
        .where(['event_group_participations.group_id = ?', group.id])
    end
  end
end
