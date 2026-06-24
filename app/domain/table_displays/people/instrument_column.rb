# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module TableDisplays::People
  class InstrumentColumn < TableDisplays::Column
    def required_permission(_attr)
      :show
    end

    def label(_attr)
      Role.human_attribute_name(:instrument)
    end

    def allowed_value_for(object, _attr, &_block)
      group = table&.try(:selected_group) || table&.template&.parent
      object.instrument_for_group(group)
    end

    def render(attr)
      super do |_target, _target_attr, object, _attr|
        allowed_value_for(object, attr)
      end
    end

    def sort_by(_attr)
      nil
    end
  end
end
