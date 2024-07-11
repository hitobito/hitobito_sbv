# frozen_string_literal: true

#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Export::Tabular::Groups
  class AddressList < List
    self.row_class = Export::Tabular::Groups::AddressRow

    def attributes
      %w[
        name type mitgliederverband regionalverband
        secondary_parent tertiary_parent
        email contact contact_email address zip_code town country
        besetzung klasse unterhaltungsmusik
        correspondence_language subventionen founding_year recognized_members
        suisa_status
      ]
    end

    private

    def row_for(entry, format = nil)
      row_class.new(entry, suisa_verein_statuses, format)
    end

    def suisa_verein_statuses
      @suisa_verein_statuses ||= fetch_suisa_verein_statuses
    end

    def fetch_suisa_verein_statuses
      calculator = CensusCalculator.new(SongCensus.current, nil)
      calculator.verein_suisa_statuses(verein_ids)
    end

    def verein_ids
      vereine = list.select { |g| g.type == Group::Verein.sti_name }
      vereine.pluck(:id)
    end
  end
end
