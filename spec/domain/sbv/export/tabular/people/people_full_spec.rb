# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"
require "csv"

describe Export::Tabular::People::PeopleFull do
  let(:person) { people(:member) }
  let(:group) { groups(:musikverband_hastdutoene) }
  let(:scope) { Person.where(id: person.id) }
  let(:export) { described_class.new(scope) }

  # Complete column set for SBV «Alle Angaben» (PeopleFull).
  # Keep in sync with PeopleAddress base attrs + Person columns + contact accounts + SBV extras.
  let(:expected_attributes) do
    [
      :first_name, :last_name, :instrument, :nickname, :company_name, :company, :email,
      :address_care_of, :street, :housenumber, :postbox, :zip_code, :town, :country,
      :layer_group, :roles, :gender, :birthday, :additional_information, :language,
      :profession, :active_years, :active_role, :personal_data_usage, :tags,
      :additional_email_privat, :additional_email_arbeit, :additional_email_vater,
      :additional_email_mutter, :additional_email_andere, :additional_email_custom_label,
      :phone_number_privat, :phone_number_mobil, :phone_number_arbeit,
      :phone_number_vater, :phone_number_mutter, :phone_number_fax, :phone_number_andere,
      :social_account_facebook, :social_account_msn, :social_account_skype,
      :social_account_twitter, :social_account_webseite, :social_account_andere,
      :social_account_custom_label
    ]
  end

  before do
    person.roles.find_by(group: group).update!(instrument: "trompete")
  end

  describe "#attributes" do
    subject { export.attributes }

    it "includes every expected Alle Angaben column in order" do
      expect(subject).to eq(expected_attributes)
    end

    it "includes SBV-specific columns" do
      expect(subject).to include(:instrument, :active_years, :profession, :personal_data_usage)
    end

    it "places instrument directly after last_name" do
      expect(subject[subject.index(:last_name) + 1]).to eq(:instrument)
    end
  end

  describe "#attribute_labels" do
    subject { export.attribute_labels }

    it "provides a non-blank label for every exported attribute" do
      export.attributes.each do |attr|
        expect(subject[attr]).to be_present, "missing label for #{attr}"
      end
    end

    it "labels instrument and active_years" do
      expect(subject[:instrument]).to eq(Role.human_attribute_name(:instrument))
      expect(subject[:active_years]).to eq(Person.human_attribute_name(:active_years))
    end
  end

  describe "CSV export" do
    let(:csv) { described_class.export(:csv, scope) }
    let(:headers) do
      line = csv.lines.first.delete_prefix(Export::Csv::UTF8_BOM.to_s)
      CSV.parse_line(line, col_sep: Settings.csv.separator.strip)
    end
    let(:row) do
      CSV.parse(
        csv.delete_prefix(Export::Csv::UTF8_BOM.to_s),
        col_sep: Settings.csv.separator.strip
      )[1]
    end

    it "writes a header for every attribute label" do
      expect(headers).to eq(export.labels)
      expect(headers.size).to eq(expected_attributes.size)
    end

    it "includes all expected header labels" do
      expected_attributes.each do |attr|
        expect(headers).to include(export.attribute_labels[attr])
      end
    end

    it "exports the instrument value" do
      idx = headers.index(Role.human_attribute_name(:instrument))
      expect(row[idx]).to eq("Trompete")
    end
  end

  describe "XLSX export" do
    it "uses the same column labels as CSV (shared attribute_labels)" do
      # Both CSV and XLSX generators write exportable.labels as headers.
      expect { described_class.export(:xlsx, scope) }.not_to raise_error
      expect(export.labels).to eq(expected_attributes.map { |attr| export.attribute_labels[attr] })
    end
  end
end
