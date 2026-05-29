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
    person.update!(instrument: "Trompete")
    table_display.update!(selected: %i[instrument])
  end

  it "always includes the base columns" do
    expect(export.attributes).to include(
      :last_name, :first_name, :nickname, :roles, :email, :zip_code, :town
    )
    expect(export.attributes).to include(:phone_number_privat)
    expect(export.attributes).to include(:additional_email_privat)
  end

  it "includes additionally selected columns such as instrument" do
    expect(export.attributes).to include(:instrument)
    idx = export.attributes.index(:instrument)
    expect(export.data_rows.first[idx]).to eq "Trompete"
  end

  it "does not include instrument when it is not selected" do
    table_display.update!(selected: [])
    expect(export.attributes).not_to include(:instrument)
  end
end
