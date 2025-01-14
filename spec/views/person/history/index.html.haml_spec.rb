#  Copyright (c) 2012-2025, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe "person/history/index.html.haml" do
  let(:group) { groups(:musikgesellschaft_alterswil) }
  let(:person) { people(:leader) }
  let(:current_user) { person }

  before do
    assign(:group, group)
    assign(:roles, person.roles)
    assign(:person, person)
    assign(:participations_by_event_type, [])
    allow(controller).to receive_messages(current_user: current_user)
  end

  subject(:dom) { Capybara::Node::Simple.new(render) }

  it "does not render form" do
    expect(dom).to have_css "table"
    expect(dom).not_to have_css "form"
  end

  context "as admin" do
    let(:current_user) { people(:admin) }

    it "renders form" do
      expect(dom).to have_css "table"
      expect(dom).to have_css "form"
    end
  end
end
