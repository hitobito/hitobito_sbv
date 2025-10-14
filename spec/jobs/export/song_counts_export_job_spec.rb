# frozen_string_literal: true

#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"
require "csv"

describe Export::SongCountsExportJob do
  subject(:root_export) {
    described_class.new(:csv, people(:admin).id, groups(:hauptgruppe_1).id, "2018", {})
  }

  subject(:bern_export) {
    # rubocop:todo Layout/LineLength
    described_class.new(:csv, people(:admin).id, groups(:bernischer_kantonal_musikverband).id, "2018",
      # rubocop:enable Layout/LineLength
      {})
  }

  let(:data_without_bom) { export.data.gsub(Regexp.new("^#{Export::Csv::UTF8_BOM}"), "") }
  let(:csv) { CSV.parse(data_without_bom, col_sep: ";", headers: true) }

  context "root layer" do
    let(:export) { root_export }
    let(:expected_data) do
      [
        {
          "Anzahl" => "12",
          "Titel" => "Fortunate Son",
          "Komponist" => "John Fogerty",
          "Arrangeur" => "Creedence Clearwater Revival",
          "Verlag" => "Fantasy",
          "SUISA-ID" => "12345",
          "Verein und Ort" => "Musikgesellschaft Aarberg, Thiloscheid"
        },
        {
          "Anzahl" => "2",
          "Titel" => "Material Girl",
          "Komponist" => "Peter Brown / Robert Rans",
          "Arrangeur" => "Madonna",
          "Verlag" => "Sire",
          "SUISA-ID" => "34567",
          "Verein und Ort" => "Musikgesellschaft Alterswil, Nord Boland"
        },
        {
          "Anzahl" => "8",
          "Titel" => "Papa Was a Rollin' Stone",
          "Komponist" => "Barrett Strong / Norman Whitfield",
          "Arrangeur" => "The Temptations",
          "Verlag" => "Motown",
          "SUISA-ID" => "23456",
          "Verein und Ort" => "Musikgesellschaft Aarberg, Thiloscheid"
        },
        {
          "Anzahl" => "4",
          "Titel" => "Papa Was a Rollin' Stone",
          "Komponist" => "Barrett Strong / Norman Whitfield",
          "Arrangeur" => "The Temptations",
          "Verlag" => "Motown",
          "SUISA-ID" => "23456",
          "Verein und Ort" => "Musikgesellschaft Alterswil, Nord Boland"
        }
      ]
    end

    it "exports all played songs with count" do
      csv.each_with_index do |row, index|
        expected_row = expected_data[index]

        expected_row.each do |key, expected_value|
          expect(row[key]).to eq(expected_value)
        end
      end
    end
  end

  context "secondary_children" do
    let(:export) { bern_export }
    let(:expected_data) do
      [
        {
          "Anzahl" => "12",
          "Titel" => "Fortunate Son",
          "Komponist" => "John Fogerty",
          "Arrangeur" => "Creedence Clearwater Revival",
          "Verlag" => "Fantasy",
          "SUISA-ID" => "12345",
          "Verein" => "Musikgesellschaft Aarberg",
          "Vereins ID" => "53161061"
        },
        {
          "Anzahl" => "8",
          "Titel" => "Papa Was a Rollin' Stone",
          "Komponist" => "Barrett Strong / Norman Whitfield",
          "Arrangeur" => "The Temptations",
          "Verlag" => "Motown",
          "SUISA-ID" => "23456",
          "Verein" => "Musikgesellschaft Aarberg",
          "Vereins ID" => "53161061"
        }
      ]
    end

    it "exports all played songs with count" do
      csv.each_with_index do |row, index|
        expected_row = expected_data[index]

        expected_row.each do |key, expected_value|
          expect(row[key]).to eq(expected_value)
        end
      end
    end
  end
end
