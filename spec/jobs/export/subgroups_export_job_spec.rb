# frozen_string_literal: true

#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"
require "csv"

describe Export::SubgroupsExportJob do
  subject(:root_export) { described_class.new(people(:admin), groups(:hauptgruppe_1).id, {}) }

  subject(:bern_export) { described_class.new(people(:admin), groups(:bernischer_kantonal_musikverband).id, {}) }

  let(:export) { root_export }
  let(:data_without_bom) { export.data.gsub(Regexp.new("^#{Export::Csv::UTF8_BOM}"), "") }
  let(:csv) { CSV.parse(data_without_bom, col_sep: ";", headers: true) }

  it "only exports Verband and Verein group types" do
    names = root_export.send(:entries).collect { |e| e.class.sti_name }.uniq
    expect(names).to eq ["Group::Mitgliederverband", "Group::Regionalverband", "Group::Verein"]
  end

  it "exports address and special columns" do
    expected_headers = [
      "Name",
      "Gruppentyp",
      "Mitgliederverband",
      "Regionalverband",
      "sekundäre Zugehörigkeit",
      "weitere Zugehörigkeit",
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
      "SUISA Status"
    ]

    expect(csv.headers).to match_array expected_headers
    expect(csv.headers).to eq expected_headers
  end

  context "secondary_children" do
    let(:export) { bern_export }
    let(:exported_group_names) { csv.map { |row| row["Name"] } }

    it "exports secondary children as well" do
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

    it "does not include duplicates when exporting secondary children" do
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

  context "data" do
    let(:export) { bern_export }

    before do
      groups(:musikgesellschaft_alterswil).update(
        secondary_parent_id: groups(:regionalverband_mittleres_seeland).id,
        tertiary_parent_id: groups(:bernischer_kantonal_musikverband).id
      )
    end

    it "secondary parent is present by name" do
      parents = csv.map { |row| row["sekundäre Zugehörigkeit"] }

      expect(parents).to match_array [
        nil,
        nil,
        nil,
        groups(:regionalverband_mittleres_seeland).name
      ]
    end

    it "tertiary parent is present by name" do
      parents = csv.map { |row| row["weitere Zugehörigkeit"] }

      expect(parents).to match_array [
        nil,
        nil,
        nil,
        groups(:bernischer_kantonal_musikverband).name
      ]
    end
  end

  context "suisa status" do
    let(:export) { root_export }
    let(:verein1) { groups(:musikgesellschaft_alterswil) }
    let!(:verein2) { create_verein }
    let!(:verein3) { create_verein }
    let!(:verein4) { create_verein }
    let!(:verein5) { create_verein }
    let(:current_year) { Time.zone.today.year }
    let(:song_census) { SongCensus.create!(year: current_year) }

    before do
      verein1.concerts.first.update!(reason: :not_playable, song_census: song_census)
      create_concert(nil, verein2)
      verein2.concerts.first.update!(song_census: nil)
      create_concert(:otherwise_billed, verein3)
      create_concert(nil, verein4)
      create_concert(nil, verein4)
      create_concert(:joint_play, verein5)
    end

    it "exports suisa status for Vereine and current year" do
      suisas = csv.each_with_object({}) { |row, h| h[row["Name"]] = row["SUISA Status"] }

      expect(suisas[verein1.name]).to eq("nicht spielfähig in diesem Jahr")
      expect(suisas[verein2.name]).to eq("nicht eingereicht")
      expect(suisas[verein3.name]).to eq("SUISA über Dritte abgerechnet")
      expect(suisas[verein4.name]).to eq("eingereicht")
      expect(suisas[verein5.name]).to eq("Spielgemeinschaft")

      # not a Verein
      expect(suisas[verein1.parent.name]).to eq(nil)
    end
  end

  private

  def create_concert(reason, verein)
    Concert.create!(reason: reason,
      verein_id: verein.id,
      song_census: song_census,
      year: current_year)
  end

  def create_verein
    Group::Verein.create!(name: "#{Faker::Space.nebula} #{Faker::Number.number}",
      parent: groups(:regionalverband_mittleres_seeland))
  end
end
