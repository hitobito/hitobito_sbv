#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe RolesController do
  let(:group)  { Fabricate(Group::Regionalverband.name.to_sym) }
  let(:verein) { Fabricate(Group::Verein.name.to_sym, parent: group, name: 'Harmonie Sursee') }
  let(:person) { Fabricate(:person) }

  context 'create history member' do
    let(:admin) { people(:admin) }

    before do
      sign_in(admin)
    end

    it 'sets attributes and creates member' do
      start_date = 3.years.ago.to_date
      end_date = 2.days.ago.to_date

      expect do
        post :create_history_member, group_id: group,
                                      role: { start_date: start_date,
                                              end_date: end_date,
                                              person_id: person.id,
                                              group_id: verein }
      end.to change{ Group::VereinMitglieder::Mitglied.with_deleted.count }.by(1)

      verien_mitglieder = verein.children.find_by(type: 'Group::VereinMitglieder')
      role = Role.with_deleted.find_by(group_id: verien_mitglieder)

      expect(role.person_id).to eq(person.id)
      expect(role.created_at.to_date).to eq(start_date)
      expect(role.deleted_at.to_date).to eq(end_date)
    end
  end

end
