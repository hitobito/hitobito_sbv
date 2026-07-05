# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module TableDisplays
  module InstrumentGroupContext
    private

    def context_group
      table&.try(:selected_group) || group_from_template
    end

    def context_group_ids
      return @context_group_ids if defined?(@context_group_ids)

      group = context_group
      @context_group_ids = group.is_a?(Group) ? group.self_and_descendants.pluck(:id) : nil
    end

    def instrument_for_person(person)
      return unless person.is_a?(Person)

      person.instrument_for_group(context_group, group_ids: context_group_ids)
    end

    def group_from_template
      template&.try(:group) || begin
        parent = table&.try(:template)&.try(:parent)
        parent.is_a?(Group) ? parent : nil
      end
    end
  end
end
