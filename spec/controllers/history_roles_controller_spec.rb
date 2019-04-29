require 'spec_helper'

describe HistoryRolesController do

  it 'POST#destroy hard destroys role and updates active_years' do
    role = roles(:suisa_admin)
    role.update(created_at: 3.years.ago)

    person = role.person
    person.update_active_years

    sign_in(roles(:leader).person)
    expect do
      post :destroy, group_id: role.group_id, id: role.id
    end.to change { role.person.roles.with_deleted.count }.by(-1)

    expect(role.person.active_years).to eq 0

    expect(flash[:notice]).to eq 'Verantwortlicher SUISA wurde erfolgreich gelöscht.'
    expect(response).to redirect_to(group_path(role.group))
  end
end
