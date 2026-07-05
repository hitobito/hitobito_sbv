# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module TableDisplays::Event::Participations
  class InstrumentColumn < ShowDetailsOrEventLeaderColumn
    def label(_attr)
      Role.human_attribute_name(:instrument)
    end

    def sort_by(_attr)
      nil
    end

    def render(attr)
      super do |_target, _target_attr, participation, _attr|
        instrument_for(participation)
      end
    end

    private

    def instrument_for(participation)
      person = participation.participant
      return unless person.is_a?(Person)

      person.instrument_for_group(context_group)
    end

    def context_group
      table&.try(:selected_group) || template&.try(:group)
    end
  end
end
