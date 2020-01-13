#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe GroupAbility do
  subject { Ability.new(role.person.reload) }
  let(:role) { Fabricate(group_role_class.name.to_sym, group: group) }

  context 'listing festivals' do
    let(:group) { groups(:hauptgruppe_1) }
    let(:group_role_class) { Group::Root::Admin }

    it { is_expected.to be_able_to(:'index_event/festivals', group) }
  end

  describe 'manage application to festivals' do
    context 'as president of a group' do
      let(:group_role_class) { Group::VereinVorstand::Praesident }
      let(:group) { groups(:vorstand_mg_aarberg)}
      let(:checked_group) { groups(:musikgesellschaft_aarberg) }

      it { is_expected.to be_able_to(:manage_festival_application, group)}
    end

    context 'as president of a group' do
      let(:group_role_class) { Group::VereinVorstand::Praesident }
      let(:group) { groups(:vorstand_mg_aarberg)}
      let(:checked_group) { groups(:musikgesellschaft_aarberg) }

      it { is_expected.to be_able_to(:manage_festival_application, checked_group)}
    end

    context 'as member of a group' do
      let(:group_role_class) { Group::VereinMitglieder::Mitglied }
      let(:group) { groups(:mitglieder_mg_aarberg)}
      let(:checked_group) { groups(:musikgesellschaft_aarberg) }

      it { is_expected.to_not be_able_to(:manage_festival_application, checked_group)}
    end

    context 'as president of a different group' do
      let(:group_role_class) { Group::VereinVorstand::Praesident }
      let(:group) { groups(:vorstand_mg_alterswil)}
      let(:checked_group) { groups(:musikgesellschaft_aarberg) }

      it { is_expected.to_not be_able_to(:manage_festival_application, checked_group)}
    end
  end
end
