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
    permission(:layer_and_below_read).may(:read).in_verein
  end

  on(SongCount) do
    class_side(:index).everybody
    permission(:any).may(:manage).all
  end

  on(SongCensus) do
    permission(:song_census).may(:manage).in_layer
  end

  def in_verein
    permission_in_group?(subject.verein_id)
  end

  def in_layer
    user.groups_with_permission(:song_census).collect(&:layer_group).include?(subject.group)
  end

end
