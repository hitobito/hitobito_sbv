# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module TableDisplays::Event::Participations
  class InstrumentColumn < ShowDetailsOrEventLeaderColumn
    include TableDisplays::InstrumentGroupContext

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
      instrument_for_person(participation.participant)
    end
  end
end
