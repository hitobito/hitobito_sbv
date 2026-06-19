# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Role::InstrumentMapper
  module_function

  def map(raw_value)
    return nil if raw_value.blank?

    normalized = raw_value.to_s.strip
    key = normalized.downcase
    return key if Sbv::Role::Instrument::INSTRUMENTS.include?(key)

    label_match(normalized)
  end

  def label_match(normalized)
    Sbv::Role::Instrument::INSTRUMENTS.find do |instrument_key|
      I18n.available_locales.any? do |locale|
        I18n.t("#{Sbv::Role::Instrument::I18N_PREFIX}.#{instrument_key}",
          locale: locale,
          default: nil) == normalized
      end
    end
  end
end
