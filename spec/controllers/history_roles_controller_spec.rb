# frozen_string_literal: true

#  Copyright (c) 2012-2021, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe HistoryRolesController do

  render_views
  it 'POST#create handles invalid start date' do
    sign_in(people(:admin))
    leader = people(:leader)
    group = groups(:mitglieder_mg_aarberg)

    role_params = {
      person_id: leader.id,
      group_id: group.id,
      start_date: 2019,
      end_date: 2020
    }
    expect do
      post :create, params: { group_id: group.id, role: role_params }
    end.not_to change { leader.roles.count }
    expect(leader.reload.active_years).to be_nil
    expect(flash[:alert].sort).to eq ['Austritt ist kein gültiges Datum', 'Eintritt ist kein gültiges Datum']
  end

  it 'POST#create is not allowed for normal members' do
    member = people(:member)
    group = groups(:mitglieder_mg_aarberg)

    sign_in(member)

    role_params = {
      person_id: member.id,
      group_id: group.id,
      start_date: 2.years.ago.to_date,
      end_date: 1.year.ago.to_date
    }
    expect do
      expect do
        post :create, params: { group_id: group.id, role: role_params }
      end.to raise_error(CanCan::AccessDenied)
    end.not_to change { member.roles.count }
    expect(member.reload.active_years).to be_nil
  end

  it 'POST#create creates new role for existing VereinMitglieder group' do
    sign_in(people(:admin))
    leader = people(:leader)
    group = groups(:mitglieder_mg_aarberg)

    role_params = {
      person_id: leader.id,
      group_id: group.id,
      start_date: 2.years.ago.to_date,
      end_date: Date.yesterday,
      label: '1. Sax'
    }
    expect do
      post :create, params: { group_id: group.id, role: role_params }
    end.to change { leader.roles.with_deleted.count }.by(1)
    expect(leader.reload.active_years).to eq 2
    expect(leader.roles.with_deleted).to be_any { |role| role.label === '1. Sax' }
  end

  it 'POST#create creates new role and deleted mitglieder verein in hidden verein group' do
    sign_in(people(:admin))
    leader = people(:leader)
    leader.update_active_years
    expect(leader.active_years).to be_zero

    role_params = {
      person_id: leader.id,
      group: { name: 'Dummy' },
      start_date: 2.years.ago.to_date,
      end_date: Date.today
    }
    expect do
      post :create, params: { group_id: leader.primary_group_id, role: role_params }
      expect(response).to redirect_to(history_group_person_path(leader.primary_group, leader))
    end.to change { leader.roles.count }.by(0)

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
      delete :destroy, params: { group_id: role.group_id, id: role.id }
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
      delete :destroy, params: { group_id: role.group_id, id: role.id }
    end.to change { role.person.roles.with_deleted.count }.by(-1)

    expect(role.person.active_years).to eq 0

    expect(flash[:notice]).to eq 'Verantwortlicher SUISA wurde erfolgreich gelöscht.'
    expect(response).to redirect_to(group_path(role.group))
  end
end
