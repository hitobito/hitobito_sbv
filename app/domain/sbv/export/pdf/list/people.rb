# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module Export::Pdf::List
    module People
      def table_header
        super.dup.tap { |row| row.insert(1, Role.human_attribute_name(:instrument)) }
      end

      def person_row(person)
        [
          person.full_name, # person_name without nickname
          instrument_for(person),
          address(person),
          person.email,
          phone_numbers(person, %w[Privat]),
          phone_numbers(person, %w[Mobil])
        ]
      end

      def instrument_for(person)
        person.instrument_for_group(title).to_s
      end
    end
  end
end
