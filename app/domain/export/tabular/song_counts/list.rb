#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Export::Tabular::SongCounts
  class List < Export::Tabular::Base

    INCLUDED_ATTRS = %w(count title composed_by arranged_by).freeze
    GROUP_ATTRS = %w(verein verein_id).freeze

    self.model_class = SongCount

    def attributes
      if list.map(&:verein_id).uniq.one?
        INCLUDED_ATTRS
      else
        INCLUDED_ATTRS + GROUP_ATTRS
      end.collect(&:to_sym)
    end
  end
end
