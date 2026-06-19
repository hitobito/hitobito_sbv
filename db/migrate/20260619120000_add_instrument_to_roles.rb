# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class AddInstrumentToRoles < ActiveRecord::Migration[8.0]
  MITGLIED_ROLE_TYPES = [
    "Role::MitgliederMitglied",
    "Group::VereinMitglieder::Mitglied"
  ].freeze

  INSTRUMENTS = %w[
    trompete fluegelhorn horn posaune bariton bassposaune tuba
    klarinette saxophon oboe fagott floete schlagzeug sonstiges
  ].freeze

  I18N_PREFIX = "activerecord.attributes.role.instruments"

  def up
    add_column :roles, :instrument, :string
    migrate_people_instrument
    migrate_role_labels
  end

  def down
    remove_column :roles, :instrument
  end

  private

  def migrate_people_instrument
    say_with_time "migrate people.instrument to active mitglied roles" do
      Person.where.not(instrument: [nil, ""]).find_each do |person|
        mapped = map_instrument(person.read_attribute(:instrument))
        next unless mapped

        active_mitglied_roles(person).where(instrument: [nil, ""]).update_all(instrument: mapped)
      end
    end
  end

  def migrate_role_labels
    say_with_time "migrate role.label to role.instrument where 1:1 match" do
      Role.where(type: MITGLIED_ROLE_TYPES)
        .where.not(label: [nil, ""])
        .where(instrument: [nil, ""])
        .find_each do |role|
        mapped = map_instrument(role.label)
        role.update_column(:instrument, mapped) if mapped
      end
    end
  end

  def active_mitglied_roles(person)
    Role.where(person_id: person.id, type: MITGLIED_ROLE_TYPES, end_on: nil)
  end

  def map_instrument(raw_value)
    return nil if raw_value.blank?

    normalized = raw_value.to_s.strip
    key = normalized.downcase
    return key if INSTRUMENTS.include?(key)

    INSTRUMENTS.find do |instrument_key|
      I18n.available_locales.any? do |locale|
        I18n.t("#{I18N_PREFIX}.#{instrument_key}", locale: locale, default: nil) == normalized
      end
    end
  end
end
