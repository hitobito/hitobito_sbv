# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module Instruments
    class Catalog
      I18N_PREFIX = "activerecord.attributes.role.instruments"
      CONFIG_PATH = Pathname.new(__dir__).join("../../../../config/instruments.json").expand_path.freeze

      class << self
        def keys
          entries.map { |entry| entry[:key].to_s }
        end

        def entries
          data.fetch(:instruments)
        end

        def label_for(key, locale: I18n.locale)
          entry = entry_for(key)
          return nil unless entry

          locale_key = locale.to_s
          entry.dig(:labels, locale_key) ||
            entry.dig(:labels, locale_key.to_sym) ||
            entry.dig(:labels, "de") ||
            entry.dig(:labels, :de)
        end

        def map(raw_value)
          return nil if raw_value.blank?

          normalized = raw_value.to_s.strip
          key = normalized.downcase

          return key if keys.include?(key)

          alias_map[key] || legacy_label_match(normalized) || label_match(normalized)
        end

        def register_i18n!
          I18n.available_locales.each do |locale|
            locale_key = locale.to_s
            instrument_labels = entries.each_with_object({}) do |entry, labels|
              label = entry.dig(:labels, locale_key) || entry.dig(:labels, locale_key.to_sym)
              labels[entry[:key].to_s] = label if label.present?
            end

            nil_label = data.dig(:nil_label, locale_key) ||
              data.dig(:nil_label, locale_key.to_sym)
            instrument_labels[I18nEnums::NIL_KEY] = nil_label if nil_label.present?

            I18n.backend.store_translations(
              locale,
              activerecord: {attributes: {role: {instruments: instrument_labels}}}
            )
          end
        end

        def reload!
          @data = nil
          @alias_map = nil
        end

        private

        def legacy_label_match(normalized)
          entries.find do |entry|
            Array(entry[:legacy_labels]).any? do |legacy_label|
              legacy_label.to_s.strip == normalized
            end
          end&.dig(:key)&.to_s
        end

        def data
          @data ||= JSON.parse(CONFIG_PATH.read, symbolize_names: true)
        end

        def entry_for(key)
          entries.find { |entry| entry[:key].to_s == key.to_s }
        end

        def alias_map
          @alias_map ||= entries.each_with_object({}) do |entry, map|
            Array(entry[:aliases]).each do |alias_key|
              map[alias_key.to_s.downcase] = entry[:key].to_s
            end
          end
        end

        def label_match(normalized)
          entries.find do |entry|
            I18n.available_locales.any? do |locale|
              label_for(entry[:key], locale: locale) == normalized
            end
          end&.dig(:key)&.to_s
        end
      end
    end
  end
end
