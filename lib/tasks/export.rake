# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

namespace :export do
  desc "Export all members"
  task members: [:environment] do
    dachverband = Group.find(1)

    extractor = DataExtraction.new("tmp/all-members.csv", ENV["RAILS_DB_NAME"])
    extractor.headers = "vorname,nachname,instrument,hauptgruppe,email,korrespondenzsprache"

    language_sql = Settings.application.languages.to_h
      .merge(Settings.application.additional_languages&.to_hash || {})
      .map do |code, long_name|
      "WHEN '#{code}' THEN '#{long_name}'"
    end.join(" ")

    instrument_sql = Sbv::Instruments::Catalog.keys.map do |key|
      label = I18n.t("#{Sbv::Role::Instrument::I18N_PREFIX}.#{key}").gsub("'", "''")
      "WHEN mitglied_roles.instrument = '#{key}' THEN '#{label}'"
    end.join("\n        ")

    extractor.query("people", <<-FIELD_SQL, <<-CONDITION_SQL)
      people.first_name,
      people.last_name,
      CASE
        #{instrument_sql}
      END AS instrument,
      layer_groups.name AS primary_group,
      people.email,
      CASE people.language
        #{language_sql}
      END AS correspondence_language
    FIELD_SQL
      INNER JOIN groups ON groups.id = people.primary_group_id
      INNER JOIN groups AS layer_groups ON layer_groups.id = groups.layer_group_id
      LEFT JOIN roles AS mitglied_roles ON mitglied_roles.person_id = people.id
        AND mitglied_roles.type = 'Group::VereinMitglieder::Mitglied'
        AND mitglied_roles.group_id = people.primary_group_id
        AND mitglied_roles.deleted_at IS NULL
        AND mitglied_roles.end_on IS NULL
      WHERE people.id IN (#{Role.where(group: dachverband.descendants).select(:person_id).uniq.to_sql.delete("`")})
    CONDITION_SQL

    extractor.dump
  end
end
