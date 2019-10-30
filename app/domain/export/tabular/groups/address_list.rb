#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Export::Tabular::Groups
  class AddressList < List
    def attributes
      %w(name type mitgliederverband contact address zip_code town country
         besetzung klasse unterhaltungsmusik)
    end
  end
end
