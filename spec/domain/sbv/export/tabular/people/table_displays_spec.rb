# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Export::Tabular::People::TableDisplays do
  let(:person) { people(:member) }
  let(:group) { groups(:musikverband_hastdutoene) }
  let(:ability) { Ability.new(person) }
  let(:table_display) { TableDisplay.for(person, Person) }
  let(:list) { Person.where(id: person.id) }

  subject(:export) { described_class.new(list, ability, table_display, group) }

  before do
    person.roles.find_by(group: group).update!(instrument: "trompete")
  end

  it "always includes the base columns including instrument" do
    expect(export.attributes).to include(
      :last_name, :first_name, :instrument, :nickname, :roles, :email, :zip_code, :town
    )
    expect(export.attributes).to include(:phone_number_privat)
    expect(export.attributes).to include(:additional_email_privat)
  end

  it "exports instrument values for the selected group" do
    idx = export.attributes.index(:instrument)
    expect(export.data_rows.first[idx]).to eq "Trompete"
  end

  it "keeps instrument in the export even when it is not selected in the table" do
    table_display.update!(selected: [])
    expect(export.attributes).to include(:instrument)
    idx = export.attributes.index(:instrument)
    expect(export.data_rows.first[idx]).to eq "Trompete"
  end
end
