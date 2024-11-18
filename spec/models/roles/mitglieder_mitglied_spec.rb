#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Role::MitgliederMitglied do
  it 'has a marker-attribute "historic membership"' do
    is_expected.to respond_to :historic_membership
    is_expected.to respond_to :historic_membership=
  end

  context 'with "historic membership"' do
    subject do
      described_class.new(
        type: "Group::VereinMitglieder::Mitglied",
        group: groups(:mitglieder_mg_aarberg),
        person: people(:member),
        start_on: 1.year.ago,
        end_on: nil,
        historic_membership: true
      )
    end

    before do
      expect(subject.historic_membership).to be true
    end

    it "is invalid without end_on" do
      expect(subject.end_on).to be_nil

      expect(subject).to_not be_valid
      expect(subject.errors.full_messages)
        .to include("Austritt ist kein gültiges Datum")
    end

    it "is invalid with future end_on" do
      subject.end_on = 1.week.from_now

      expect(subject).to_not be_valid
      expect(subject.errors.full_messages)
        .to include("Austritt kann nicht später als heute sein")
    end

    it "is valid with end_on in the past" do
      subject.end_on = 1.week.ago

      expect(subject).to be_valid
    end
  end
end
