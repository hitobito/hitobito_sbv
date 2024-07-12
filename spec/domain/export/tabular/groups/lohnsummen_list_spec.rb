# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"
require "csv"

describe Export::Tabular::Groups::LohnsummenList do
  let(:data) { described_class.csv(list) }
  let(:data_without_bom) { data.gsub(Regexp.new("^#{Export::Csv::UTF8_BOM}"), "") }
  let(:csv) { CSV.parse(data_without_bom, headers: true, col_sep: Settings.csv.separator) }

  subject { csv }

  let(:list) do
    groups(:regionalverband_mittleres_seeland)
      .descendants
      .where(type: "Group::Verein")
  end

  its(:headers) do
    is_expected.to eql ["Name", "BUV-Lohnsumme", "NBUV-Lohnsumme"]
  end

  it "has 1 item" do
    expect(subject.size).to eq(1)
  end

  context "first row" do
    subject { csv[0] }

    its(["Name"]) { is_expected.to eql "Musikgesellschaft Aarberg" }
    its(["BUV-Lohnsumme"]) { is_expected.to eql "1337.00" }
    its(["NBUV-Lohnsumme"]) { is_expected.to eql "42.23" }
  end
end
