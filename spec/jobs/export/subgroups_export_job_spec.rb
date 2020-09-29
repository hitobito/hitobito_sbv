#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'
require 'csv'

describe Export::SubgroupsExportJob do
  subject { described_class.new(people(:admin), groups(:hauptgruppe_1).id, {}) }

  it 'only exports Verband and Verein group types' do
    names = subject.send(:entries).collect { |e| e.class.sti_name }.uniq
    expect(names).to eq ["Group::Mitgliederverband", "Group::Regionalverband", "Group::Verein"]
  end

  it ' exports address and special columns' do
    csv = CSV.parse(subject.data, col_sep: ';', headers: true)
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

end
