# frozen_string_literal: true

#  Copyright (c) 2019-2023, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module Group::NestedSet
    extend ActiveSupport::Concern

    included do
      def direct_children_of(group)
        group.children.where(parent_id: group.id)
      end

      # rubocop:disable Style/IfInsideElse,Style/RedundantSelf,Rails/FindEach
      # copied from awesome_nested_set to accomodate for a little change
      def find_left_neighbor(parent, order_attribute, ascending)
        left = nil

        # change from upsteam version to omit secondary and tertiary children
        direct_children_of(parent).each do |n|
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

    def move_required?
      (@move_to_new_parent_id != false || @move_to_new_name != false) &&
        parent_id &&
        direct_children_of(parent).count > 1
    end

    def move_to_most_left_if_change
      first = direct_children_of(parent).first
      move_to_left_of(first) unless first == self
    end
  end
end
