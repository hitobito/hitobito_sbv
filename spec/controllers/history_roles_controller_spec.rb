#  Copyright (c) 2012-2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe HistoryRolesController do

  it 'POST#create creates new role for existing VereinMitglieder group' do
    sign_in(people(:admin))
    leader = people(:leader)
    group = groups(:mitglieder_mg_aarberg)

    role_params = {
      person_id: leader.id,
      group_id: group.id,
      start_date: 2.years.ago.to_date
    }
    expect do
      post :create, group_id: group.id, role: role_params
      expect(response).to redirect_to(history_group_person_path(group.id, leader))
    end.to change { leader.roles.count }.by(1)
    expect(leader.reload.active_years).to eq 2
  end

  it 'POST#create creates new role and deleted mitglieder verein in hidden verein group' do
    sign_in(people(:admin))
    leader = people(:leader)

    role_params = {
      person_id: leader.id,
      group: { name: 'Dummy' },
      start_date: 2.years.ago.to_date
    }
    expect do
      post :create, group_id: leader.primary_group_id, role: role_params
      expect(response).to redirect_to(history_group_person_path(leader.primary_group, leader))
    end.to change { leader.roles.count }.by(1)
    expect(leader.reload.active_years).to eq 2
    expect(Group::Verein.hidden).to have(1).children
    group = Group::Verein.hidden.children.find_by(name: 'Dummy')
    expect(group).to be_deleted
  end

  it 'DELETE#destroy hard destroys role and updates active_years' do
    role = roles(:suisa_admin)
    role.update(created_at: 3.years.ago)

    person = role.person
    person.update_active_years

    sign_in(people(:leader))
    expect do
      delete :destroy, group_id: role.group_id, id: role.id
    end.to change { role.person.roles.with_deleted.count }.by(-1)

    expect(role.person.active_years).to eq 0

    expect(flash[:notice]).to eq 'Verantwortlicher SUISA wurde erfolgreich gelöscht.'
    expect(response).to redirect_to(group_path(role.group))
  end

  it 'DELETE#destroy hard destroys deleted role and updates active_years' do
    role = roles(:suisa_admin)
    role.update(created_at: 3.years.ago, deleted_at: 10.days.ago)

    person = role.person
    person.update_active_years

    sign_in(people(:leader))
    expect do
      delete :destroy, group_id: role.group_id, id: role.id
    end.to change { role.person.roles.with_deleted.count }.by(-1)

    expect(role.person.active_years).to eq 0

    expect(flash[:notice]).to eq 'Verantwortlicher SUISA wurde erfolgreich gelöscht.'
    expect(response).to redirect_to(group_path(role.group))
  end
end
