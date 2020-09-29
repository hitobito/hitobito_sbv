# frozen_string_literal: true

#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'
require 'csv'

describe Export::SubgroupsExportJob do
  subject(:root_export) { described_class.new(people(:admin), groups(:hauptgruppe_1).id, {}) }
  subject(:bern_export) { described_class.new(people(:admin), groups(:bernischer_kantonal_musikverband).id, {}) }

  it 'only exports Verband and Verein group types' do
    names = root_export.send(:entries).collect { |e| e.class.sti_name }.uniq
    expect(names).to eq ["Group::Mitgliederverband", "Group::Regionalverband", "Group::Verein"]
  end

  it ' exports address and special columns' do
    csv = CSV.parse(root_export.data, col_sep: ';', headers: true)
    expected_headers = [
      "Name",
      "Gruppentyp",
      "Mitgliederverband",
      "Regionalverband",
      "sekundär",
      "weitere",
      "Haupt-E-Mail",
      "Kontaktperson",
      "E-Mailadresse Kontaktperson",
      "Adresse",
      "PLZ",
      "Ort",
      "Land",
      "Besetzung",
      "Klasse",
      "Unterhaltungsmusik",
      "Korrespondenzsprache",
      "Subventionen",
      "Gründungsjahr",
      "Erfasste Mitglieder",
    ]
    expect(csv.headers).to match_array expected_headers
    expect(csv.headers).to eq expected_headers
  end

  context 'secondary_children' do
    let(:exported_group_names) do
      csv = CSV.parse(bern_export.data, col_sep: ';', headers: true)
      csv.map { |row| row['Name'] }
    end

    it 'exports secondary children as well' do
      groups(:musikgesellschaft_alterswil).update(
        secondary_parent_id: groups(:regionalverband_mittleres_seeland).id
      )

      expect(exported_group_names).to match_array [
        groups(:bernischer_kantonal_musikverband).name,
        groups(:regionalverband_mittleres_seeland).name,
        groups(:musikgesellschaft_aarberg).name,
        groups(:musikgesellschaft_alterswil).name
      ]
    end

    it 'does not include duplicates when exporting secondary children' do
      groups(:musikgesellschaft_aarberg).update(
        secondary_parent_id: groups(:bernischer_kantonal_musikverband).id
      )

      expect(exported_group_names).to match_array [
        groups(:bernischer_kantonal_musikverband).name,
        groups(:regionalverband_mittleres_seeland).name,
        groups(:musikgesellschaft_aarberg).name
      ]
    end
  end

end
