# encoding: utf-8

#  Copyright (c) 2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module Export
    module Tabular
      module People
        module PeopleFull
          extend ActiveSupport::Concern

          included do
            alias_method_chain :person_attributes, :active_years
          end

          def person_attributes_with_active_years
            person_attributes_without_active_years + [:active_years]
          end
        end
      end
    end
  end
end
