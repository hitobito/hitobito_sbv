# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SongAbility < AbilityDsl::Base

  on(Song) do
    class_side(:index).everybody
    permission(:any).may(:manage).all
  end

  on(SongCensus) do
    class_side(:index).everybody
    permission(:any).may(:manage).all
  end

end
