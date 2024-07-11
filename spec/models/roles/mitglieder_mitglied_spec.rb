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
        created_at: 1.year.ago,
        deleted_at: nil,
        historic_membership: true
      )
    end

    before do
      expect(subject.historic_membership).to be true
    end

    it "is invalid without deleted_at" do
      expect(subject.deleted_at).to be_nil

      expect(subject).to_not be_valid
      expect(subject.errors.full_messages)
        .to include("Austritt ist kein gültiges Datum")
    end

    it "is invalid with future deleted_at" do
      subject.deleted_at = 1.week.from_now

      expect(subject).to_not be_valid
      expect(subject.errors.full_messages)
        .to include("Austritt kann nicht später als heute sein")
    end

    it "is valid with deleted_at in the past" do
      subject.deleted_at = 1.week.ago

      expect(subject).to be_valid
    end
  end
end
