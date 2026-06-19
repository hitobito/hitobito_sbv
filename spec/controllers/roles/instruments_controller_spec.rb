# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Roles::InstrumentsController do
  render_views

  let(:person) { people(:member) }
  let(:group) { groups(:musikverband_hastdutoene) }
  let(:role) do
    person.roles.find_by(group: group).tap { |r| r.update!(instrument: "saxophon") }
  end

  it "DELETE#destroy removes instrument but keeps role" do
    sign_in(people(:admin))

    expect do
      delete :destroy, params: { group_id: group.id, role_id: role.id }, format: :js
    end.not_to change { person.roles.count }

    expect(role.reload.instrument).to be_nil
    expect(response).to be_successful
    expect(response.body).to include("section.instruments")
  end

  it "DELETE#destroy is not allowed for normal members" do
    sign_in(person)

    expect do
      delete :destroy, params: { group_id: group.id, role_id: role.id }, format: :js
    end.to raise_error(CanCan::AccessDenied)

    expect(role.reload.instrument).to eq("saxophon")
  end
end
