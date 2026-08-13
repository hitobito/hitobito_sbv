# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Role::Instrument
  extend ActiveSupport::Concern

  INSTRUMENTS = %w[
    querfloete
    piccolo
    oboe
    englischhorn
    fagott
    es_klarinette
    klarinette
    bassklarinette
    saxophon_sopran
    saxophon_alt
    saxophon_tenor
    saxophon_bariton
    saxophon_bass
    trompete
    fluegelhorn
    cornet
    waldhorn
    tenorhorn
    posaune
    bariton
    euphonium
    bassposaune
    tuba
    kontrabass
    schlagzeug
    sonstiges
  ].freeze

  I18N_PREFIX = "activerecord.attributes.role.instruments"

  included do
    include I18nEnums

    self.used_attributes += [:instrument]
    paper_trail_options[:skip] |= [:label]

    i18n_enum :instrument, INSTRUMENTS,
      key: :instruments,
      i18n_prefix: I18N_PREFIX
  end

  module ClassMethods
    def mitglied_role_types
      descendants.map(&:sti_name) + [sti_name]
    end

    def instruments
      INSTRUMENTS
    end
  end

  def mitglied?
    is_a?(Role::MitgliederMitglied)
  end
end
