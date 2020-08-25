# frozen_string_literal: true

#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Event::GroupParticipationAbility < AbilityDsl::Base
  on(Event::GroupParticipation) do
    class_side(:index).everybody

    permission(:any).may(:show).if_festival_organizer
    permission(:any)
      .may(:edit, :edit_stage, :update, :destroy).if_festival_organizer

    permission(:festival_participation)
      .may(:show).their_application

    permission(:festival_participation)
      .may(:edit, :edit_stage, :update)
      .their_application_during_the_application_period

    permission(:festival_participation)
      .may(:create, :destroy)
      .their_own_application_during_the_application_period
  end

  def if_festival_organizer
    event_contact    = (subject.event.contact == user)
    group_permission = permission_in_groups?(subject.event.group_ids)

    event_contact || group_permission
  end

  def their_application_during_the_application_period
    their_application if subject.event.application_possible?
  end

  def their_own_application_during_the_application_period
    their_own_application if subject.event.application_possible?
  end

  def their_application
    their_own_application || their_supporting_application
  end

  private

  def their_own_application
    layer_permission_for(subject.group)
  end

  def their_supporting_application
    layer_permission_for(subject.secondary_group)
  end

  def layer_permission_for(group)
    group && permission_in_layer?(group.layer_group_id)
  end
end
