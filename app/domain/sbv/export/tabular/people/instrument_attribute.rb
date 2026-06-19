# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module Export
    module Tabular
      module People
        module InstrumentAttribute
          extend ActiveSupport::Concern

          NAME_ATTRIBUTES = %i[last_name name first_name].freeze

          module_function

          def insert_instrument_after_name_attribute(attributes)
            return attributes if attributes.include?(:instrument)

            name_attribute = NAME_ATTRIBUTES.find { |attr| attributes.include?(attr) }
            return attributes + [:instrument] unless name_attribute

            index = attributes.index(name_attribute)
            attributes.dup.insert(index + 1, :instrument)
          end

          included do
            alias_method :person_attributes_without_instrument, :person_attributes
            alias_method :person_attributes, :person_attributes_with_instrument
          end

          def person_attributes_with_instrument
            InstrumentAttribute.insert_instrument_after_name_attribute(
              person_attributes_without_instrument
            )
          end

          def instrument_label
            Role.human_attribute_name(:instrument)
          end
        end
      end
    end
  end
end
