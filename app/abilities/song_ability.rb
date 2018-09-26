# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SongAbility < AbilityDsl::Base

  on(Song) do
    permission(:song_census).may(:manage).all
  end

  on(SongCount) do
    permission(:song_census).may(:manage).in_verein
    permission(:song_census).may(:submit).in_verein
    permission(:layer_and_below_read).may(:read).in_verein
  end

  on(Concert) do
    permission(:song_census).may(:manage).in_verein
    permission(:layer_and_below_read).may(:read).in_verein
  end

  on(Group) do
    permission(:song_census).may(:index_song_counts).in_same_group
    permission(:song_census).may(:manage_song_census).in_layer
  end

  def in_same_group
    permission_in_group?(subject.id)
  end

  def in_verein
    permission_in_group?(subject.verein_id)
  end

  def in_layer
    subject.self_and_ancestors.any? do |group|
      user.groups_with_permission(:song_census).include?(group)
    end
  end

end
