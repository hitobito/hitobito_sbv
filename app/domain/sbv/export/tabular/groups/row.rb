# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
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
