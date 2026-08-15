# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"
require "csv"

describe "PeopleFull / PeopleAddress CSV instrument column" do
  let(:person) { people(:member) }
  let(:group) { groups(:musikverband_hastdutoene) }

  before do
    person.roles.find_by(group: group).update!(instrument: "trompete")
  end

  def csv_headers(csv)
    CSV.parse_line(csv.lines.first, col_sep: Settings.csv.separator.strip)
  end

  it "includes Instrument header and value for Alle Angaben (PeopleFull)" do
    csv = Export::Tabular::People::PeopleFull.export(:csv, Person.where(id: person.id))
    headers = csv_headers(csv)
    expect(headers).to include("Instrument")
    idx = headers.index("Instrument")
    row = CSV.parse(csv, col_sep: Settings.csv.separator.strip)[1]
    expect(row[idx]).to eq("Trompete")
  end

  it "includes Instrument header for Adressen (PeopleAddress)" do
    csv = Export::Tabular::People::PeopleAddress.export(:csv, Person.where(id: person.id))
    expect(csv_headers(csv)).to include("Instrument")
  end
end
