# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module Export
    module Tabular
      module People
        module TableDisplaysExtension
          # Standard columns for «Spaltenauswahl», plus additionally selected columns.
          BASE_PERSON_ATTRS = %i[last_name first_name nickname roles email zip_code town].freeze

          def build_attribute_labels
            base_export_attribute_labels.merge(additional_selected_labels)
          end

          private

          def base_export_attribute_labels
            @base_export_attribute_labels ||= BASE_PERSON_ATTRS
              .index_with { |attr| attribute_label(attr) }
              .merge(association_attributes)
          end

          def additional_selected_labels
            selected_labels.reject { |attr, _| base_export_attribute_labels.key?(attr) }
          end
        end
      end
    end
  end
end
