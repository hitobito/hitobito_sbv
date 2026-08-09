# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Sbv::Export::Tabular::People::InstrumentAttribute do
  describe ".insert_instrument_after_name_attribute" do
    it "inserts instrument after last_name" do
      attributes = %i[first_name last_name email]
      expect(described_class.insert_instrument_after_name_attribute(attributes))
        .to eq(%i[first_name last_name instrument email])
    end

    it "inserts instrument after name for household exports" do
      attributes = %i[salutation name zip_code]
      expect(described_class.insert_instrument_after_name_attribute(attributes))
        .to eq(%i[salutation name instrument zip_code])
    end

    it "does not duplicate instrument" do
      attributes = %i[first_name last_name instrument email]
      expect(described_class.insert_instrument_after_name_attribute(attributes))
        .to eq(attributes)
    end
  end

  describe Export::Tabular::People::PeopleAddress do
    subject { described_class.new([person]).send(:person_attributes) }

    let(:person) { people(:member) }

    it "includes instrument after the name attributes" do
      last_name_index = subject.index(:last_name)
      expect(subject[last_name_index + 1]).to eq(:instrument)
    end
  end

  describe Export::Tabular::People::PeopleFull do
    subject { described_class.new(Person.where(id: person.id)).send(:person_attributes) }

    let(:person) { people(:member) }

    it "includes instrument after the name attributes" do
      last_name_index = subject.index(:last_name)
      expect(subject[last_name_index + 1]).to eq(:instrument)
    end

    it "includes instrument in exported attributes" do
      attrs = described_class.new(Person.where(id: person.id)).attributes
      expect(attrs).to include(:instrument)
    end
  end
end
