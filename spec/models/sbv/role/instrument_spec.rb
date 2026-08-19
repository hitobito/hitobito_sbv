# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

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

  it "translates instrument labels via i18n_enum" do
    subject.instrument = "saxophon_sopran"
    expect(subject.instrument_label).to eq "Sopransaxophon"
    expect(described_class.instrument_labels[:saxophon_alt]).to eq "Altsaxophon"
  end

  it "keeps catalog order for select options" do
    expect(described_class.instruments.first).to eq "piccolo"
    expect(described_class.instruments).to include("althorn", "klavier")
    expect(described_class.instruments).not_to include("sonstiges", "cornet", "tuba")
  end

  it "does not track label changes in paper trail", versioning: true do
    subject.update!(instrument: nil, label: "Alt")

    expect { subject.update!(instrument: "oboe", label: "Neu") }
      .to change { PaperTrail::Version.count }.by(1)

    changes = PaperTrail::Version.last.changeset.keys
    expect(changes).to include("instrument")
    expect(changes).not_to include("label")
  end
end

describe Person do
  let(:person) { people(:member) }
  let(:group) { groups(:musikverband_hastdutoene) }

  it "returns instrument for the group context" do
    person.roles.find_by(group: group).update!(instrument: "posaune")
    expect(person.instrument_for_group(group)).to eq "Posaune"
  end

  it "ignores non-group values for group context lookup" do
    person.roles.find_by(group: group).update!(instrument: "posaune")
    expect(person.instrument_for_group(group.name)).to be_nil
  end

  it "returns instrument via primary group" do
    person.roles.find_by(group: group).update!(instrument: "posaune")
    expect(person.instrument).to eq "Posaune"
  end
end
