# encoding: utf-8

#  Copyright (c) 2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.


module Sbv
  module Export
    module Tabular
      module Groups
        module List
          extend ActiveSupport::Concern
          
          included do
            alias_method_chain :attributes, :recognized_members
          end

          def attributes_with_recognized_members
            attributes_without_recognized_members + [:recognized_members]
          end

        end
      end
    end
  end
end
