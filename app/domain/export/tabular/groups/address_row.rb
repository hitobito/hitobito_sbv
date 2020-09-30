# frozen_string_literal: true

#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Export::Tabular::Groups
  class AddressRow < Row
    def secondary_parent
      other_parent_name(entry.secondary_parent_id)
    end

    def tertiary_parent
      other_parent_name(entry.tertiary_parent_id)
    end

    private

    def other_parent_name(id)
      Group.where(id: id).pluck(:name).first if id.present?
    end
  end
end
