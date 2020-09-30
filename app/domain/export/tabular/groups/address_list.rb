# frozen_string_literal: true

#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Export::Tabular::Groups
  class AddressList < List
    self.row_class = Export::Tabular::Groups::AddressRow

    def attributes
      %w(
        name type mitgliederverband regionalverband
        secondary_parent tertiary_parent
        email contact contact_email address zip_code town country
        besetzung klasse unterhaltungsmusik
        correspondence_language subventionen founding_year recognized_members
      )
    end
  end
end
