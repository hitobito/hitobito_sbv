# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Sbv::Role::InstrumentMapper do
  describe ".map" do
    it "maps exact enum keys" do
      expect(described_class.map("trompete")).to eq "trompete"
    end

    it "maps exact translated labels" do
      expect(described_class.map("Trompete")).to eq "trompete"
      expect(described_class.map("Alt-Saxophon")).to eq "saxophon_alt"
    end

    it "maps legacy saxophon alias to alt saxophon" do
      expect(described_class.map("saxophon")).to eq "saxophon_alt"
      expect(described_class.map("Saxophon")).to eq "saxophon_alt"
    end

    it "returns nil for non-matching values" do
      expect(described_class.map("1. Sax")).to be_nil
      expect(described_class.map("Random")).to be_nil
    end
  end
end

describe Role::MitgliederMitglied do
  subject { roles(:member) }

  it "validates instrument inclusion" do
    subject.instrument = "invalid"
    expect(subject).not_to be_valid
    expect(subject.errors[:instrument]).to be_present
  end

  it "accepts valid instruments" do
    subject.instrument = "saxophon_tenor"
    expect(subject).to be_valid
  end

  it "translates instrument labels" do
    subject.instrument = "saxophon_sopran"
    expect(subject.instrument_label).to eq "Sopran-Saxophon"
  end
end

describe Person do
  let(:person) { people(:member) }
  let(:group) { groups(:musikverband_hastdutoene) }

  it "returns instrument for the group context" do
    person.roles.find_by(group: group).update!(instrument: "posaune")
    expect(person.instrument_for_group(group)).to eq "Posaune"
  end

  it "returns instrument via primary group" do
    person.roles.find_by(group: group).update!(instrument: "posaune")
    expect(person.instrument).to eq "Posaune"
  end
end
