# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe PaperTrail::VersionAssociationChangePresenter, :draper_with_helpers, versioning: true do
  let(:person) { people(:member) }
  let(:group) { groups(:mitglieder_hastdutoene) }
  let(:view_context) { ActionController::Base.new.view_context }
  let(:presenter) { described_class.new(version, view_context) }

  before do
    PaperTrail.request.whodunnit = people(:admin).id.to_s
    view_context.extend(FormatHelper)
  end

  subject { presenter.render }

  def create_mitglied(instrument: nil)
    Group::VereinMitglieder::Mitglied.create!(
      person: person,
      group: group,
      start_on: Time.zone.today,
      instrument: instrument
    )
  end

  context "role create" do
    let(:version) { PaperTrail::Version.where(item: role, event: "create").last }

    context "with instrument" do
      let!(:role) { create_mitglied(instrument: "piccolo") }

      it "includes the instrument in the create text" do
        is_expected.to include("wurde hinzugefügt:")
        is_expected.to include("Instrument wurde auf <i>Piccolo</i> gesetzt.")
      end
    end

    context "without instrument" do
      let!(:role) { create_mitglied }

      it "does not show a dangling colon" do
        is_expected.to include("wurde hinzugefügt.")
        is_expected.not_to include("hinzugefügt:")
      end
    end
  end

  context "role update" do
    let!(:role) { create_mitglied }
    let(:version) { PaperTrail::Version.where(main_id: person.id).order(:id).last }

    it "logs instrument assignment without a spurious leading comma" do
      role.update!(instrument: "oboe", label: "")

      expect(subject).to include("Instrument wurde auf <i>Oboe</i> gesetzt.")
      expect(subject).not_to match(/aktualisiert: ,/)
    end
  end
end
