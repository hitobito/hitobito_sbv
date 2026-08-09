# frozen_string_literal: true

require "spec_helper"

describe Export::Tabular::People::PeopleFull do
  let(:person) { people(:top_leader) }
  let(:export) { described_class.new(Person.where(id: person.id)) }

  it "excludes personal_data_usage from alle angaben export" do
    expect(export.send(:person_attributes)).not_to include(:personal_data_usage)
  end
end
