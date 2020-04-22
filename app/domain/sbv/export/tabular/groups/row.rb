# encoding: utf-8

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module Export
    module Tabular
      module Groups
        module Row
          extend ActiveSupport::Concern

          def besetzung
            translated_label(:besetzung)
          end

          def klasse
            translated_label(:klasse)
          end

          def unterhaltungsmusik
            translated_label(:unterhaltungsmusik)
          end

          def correspondence_language
            Settings.application.languages.to_h.stringify_keys[entry.correspondence_language]
          end

          def contact_email
            if entry.contact
              entry.contact.email
            end
          end

          # rubocop:disable Style/FormatString
          def buv_lohnsumme
            if entry.buv_lohnsumme
              '%#.2f' % entry.buv_lohnsumme
            end
          end

          def nbuv_lohnsumme
            if entry.nbuv_lohnsumme
              '%#.2f' % entry.nbuv_lohnsumme
            end
          end
          # rubocop:enable Style/FormatString

          private

          def translated_label(method)
            method = "#{method}_label" if entry.is_a?(::Group::Verein)
            entry.send(method)
          end
        end
      end
    end
  end
end
