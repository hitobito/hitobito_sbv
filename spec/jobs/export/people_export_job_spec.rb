# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Export::PeopleExportJob do
  include JobObservationSpecHelper

  let(:user) { people(:admin) }
  let(:group) { groups(:musikgesellschaft_alterswil) }
  let(:mitglieder) { groups(:mitglieder_38) }
  let(:person) { people(:leader) }
  let(:file) { subject.job_observation }

  before do
    Fabricate(
      Group::VereinMitglieder::Mitglied.sti_name.to_sym,
      group: mitglieder,
      person: person,
      instrument: "trompete"
    )
    subject.enqueue!
  end

  context "full export" do
    subject do
      Export::PeopleExportJob.new(
        :csv, user.id, group.id, {}, full: true, filename: "people_export"
      )
    end

    it "includes the instrument column" do
      subject.perform
      header = read_data_from_generated_file(file).lines.first
      expect(header).to include("Instrument")
    end
  end

  context "selection export" do
    subject do
      Export::PeopleExportJob.new(
        :csv, user.id, group.id, {}, selection: true, filename: "people_export"
      )
    end

    before do
      TableDisplay.for(user, Person).update!(selected: %i[instrument])
    end

    it "includes base columns and instrument when selected" do
      subject.perform
      csv = CSV.parse(
        read_data_from_generated_file(file),
        col_sep: Settings.csv.separator.strip,
        headers: true
      )
      headers = csv.headers.map { |h| h.to_s.delete("\uFEFF") }
      expect(headers).to include("Nachname", "Vorname", "Instrument")
      expect(csv["Instrument"]).to include("Trompete")
    end
  end
end
