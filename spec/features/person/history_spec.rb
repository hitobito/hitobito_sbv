# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Alpen-Club. This file is part of
#  hitobito_sac_cas and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito

require "spec_helper"

describe :person_history, js: true do
  let(:role) { roles(:admin) }
  let(:person) { role.person }

  before { sign_in(person) }

  context "role creation" do
    it "is possible to create new role" do
      visit history_group_person_path(group_id: role.group_id, id: person.id)

      click_on "Neue Rolle"
      find("#role_group").set("Musikverband HastDuTöne")
      find("li#autoComplete_result_0").click
      find("#role_start_on").set("12.12.2015")
      find("#role_end_on").set("12.12.2016")
      click_on "Speichern"

      expect(page).to have_text "Mitglied (bis 12.12.2016) wurde erfolgreich erstellt."

      expect(person.roles.with_inactive.last.start_on).to eq Date.new(2015, 12, 12)
      expect(person.roles.with_inactive.last.end_on).to eq Date.new(2016, 12, 12)
    end
  end
end
