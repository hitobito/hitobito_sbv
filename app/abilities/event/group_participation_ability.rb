# frozen_string_literal: true

#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Event::GroupParticipationAbility < AbilityDsl::Base
  on(Event::GroupParticipation) do
    permission(:any).may(:show, :index).if_festival_organizer
  end

  def if_festival_organizer
    event_contact    = (subject.event.contact == user)
    group_permission = permission_in_groups?(subject.event.group_ids)

    event_contact || group_permission
  end
end
