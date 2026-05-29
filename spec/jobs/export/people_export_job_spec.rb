# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Export::PeopleExportJob do
  let(:user) { people(:admin) }
  let(:group) { groups(:musikverband_hastdutoene) }
  let(:person) { people(:member) }
  let(:filename) { AsyncDownloadFile.create_name("people_export", user.id) }

  before do
    person.update!(instrument: "Trompete")
  end

  context "full export" do
    subject do
      Export::PeopleExportJob.new(:csv, user.id, group.id, {}, full: true, filename: filename)
    end

    it "includes the instrument column" do
      subject.perform
      header = AsyncDownloadFile.from_filename(filename, :csv).read.lines.first
      expect(header).to include("Instrument")
    end
  end

  context "selection export" do
    subject do
      Export::PeopleExportJob.new(:csv, user.id, group.id, {}, selection: true, filename: filename)
    end

    before do
      TableDisplay.for(user, Person).update!(selected: %i[instrument])
    end

    it "includes base columns and instrument when selected" do
      subject.perform
      csv = CSV.parse(
        AsyncDownloadFile.from_filename(filename, :csv).read,
        col_sep: Settings.csv.separator.strip,
        headers: true
      )
      expect(csv.headers).to include("Nachname", "Vorname", "Instrument")
      expect(csv.first["Instrument"]).to eq "Trompete"
    end
  end
end
