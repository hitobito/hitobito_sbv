# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Role::Instrument
  extend ActiveSupport::Concern

  I18N_PREFIX = Sbv::Instruments::Catalog::I18N_PREFIX

  included do
    include I18nEnums

    self.used_attributes += [:instrument]
    paper_trail_options[:skip] |= [:label]

    i18n_enum :instrument, ->(_) { Sbv::Instruments::Catalog.keys },
      key: :instruments,
      i18n_prefix: I18N_PREFIX
  end

  module ClassMethods
    def mitglied_role_types
      descendants.map(&:sti_name) + [sti_name]
    end

    def map_instrument_value(raw_value)
      Sbv::Role::InstrumentMapper.map(raw_value)
    end

    def instruments
      Sbv::Instruments::Catalog.keys
    end
  end

  def mitglied?
    is_a?(Role::MitgliederMitglied)
  end
end
