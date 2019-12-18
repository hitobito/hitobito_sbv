class Event::GroupParticipationAbility < AbilityDsl::Base
  on(Event::GroupParticipation) do
    permission(:group_and_below_read).may(:index).in_layer
    permission(:group_and_below_full).may(:any).in_layer
  end


  def in_layer
    subject.self_and_ancestors.any? do |group|
      user.groups_with_permission(:song_census).include?(group)
    end
  end
end
