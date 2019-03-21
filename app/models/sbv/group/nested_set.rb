#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module Group::NestedSet
    private

    # rubocop:disable Style/IfInsideElse,Style/RedundantSelf,Rails/FindEach
    # copied from awesome_nested_set to accomodate for a little change
    def find_left_neighbor(parent, order_attribute, ascending)
      left = nil

      # change from upsteam version to omit secondary and tertiary children
      parent.children.where(parent_id: parent.id).each do |n|
        if ascending
          left = n if n.send(order_attribute) < self.send(order_attribute)
        else
          left = n if n.send(order_attribute) > self.send(order_attribute)
        end
      end
      left
    end
    # rubocop:enable Style/IfInsideElse,Style/RedundantSelf,Rails/FindEach
  end
end
