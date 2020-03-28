# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Export::Tabular::SongCounts
  class Row < Export::Tabular::Row
    def verein_with_town
      [entry.verein, entry.verein.town].compact.join(', ')
    end
  end
end
