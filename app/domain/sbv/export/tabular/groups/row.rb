# frozen_string_literal: true

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


          def initialize(entry, suisa_verein_statuses, format = nil)
            @suisa_verein_statuses = suisa_verein_statuses
            super(entry, format)
          end

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
            Settings.application.correspondence_languages
                    .to_h.stringify_keys[entry.correspondence_language.to_s]
          end

          def contact_email
            entry.contact&.email
          end

          # rubocop:disable Style/FormatString,Style/FormatStringToken
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
          # rubocop:enable Style/FormatString,Style/FormatStringToken

          def suisa_status
            if entry.is_a?(::Group::Verein)
              translated_suisa_status(entry)
            end
          end

          private

          def translated_label(method)
            method = "#{method}_label" if entry.is_a?(::Group::Verein)
            entry.send(method)
          end

          def translated_suisa_status(verein)
            reason = @suisa_verein_statuses[verein.id]
            reason ||= 'not_submitted'
            I18n.t("song_censuses.totals.#{reason}")
          end

        end
      end
    end
  end
end
