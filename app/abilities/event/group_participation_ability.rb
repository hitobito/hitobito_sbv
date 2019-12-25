#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Event::GroupParticipationAbility < AbilityDsl::Base
  on(Event::GroupParticipation) do
    permission(:group_and_below_read).may(:index).in_layer
    permission(:group_and_below_full).may(:any).in_layer
  end

  def in_layer
    subject.group.self_and_ancestors.any? do |group|
      user.groups_with_permission(:festival_participation).include?(group)
    end
  end
end
