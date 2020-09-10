# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Event::GroupParticipationAbility do
  include ActiveSupport::Testing::TimeHelpers

  subject { Ability.new(role.person.reload) }
  let(:role) { Fabricate(group_role_class.name.to_sym, group: group) }

  let(:organizer_group)   { groups(:hauptgruppe_1) }
  let(:participant_group) { groups(:musikgesellschaft_alterswil) }
  let(:other_group)       { groups(:musikverband_hastdutoene) }

  let(:festival) { Fabricate(:festival) }
  let(:application_open)  { festival.application_opening_at }
  let(:application_close) { festival.application_closing_at }

  let(:group_participation) do
    Fabricate(:group_participation, group: participant_group, event: festival)
  end

  let(:new_group_participation) do
    Fabricate.build(:group_participation, group: participant_group, event: festival)
  end

  context 'during the application period' do
    before { travel_to(application_open.succ) }
    after { travel_back }

    context 'a festival organizer' do
      let(:group) { organizer_group }
      let(:group_role_class) { Group::Root::Admin }

      it { is_expected.to     be_able_to(:show,    group_participation) }
      it { is_expected.to     be_able_to(:index,   group_participation.class) }
      it { is_expected.to_not be_able_to(:new,     new_group_participation) }
      it { is_expected.to_not be_able_to(:create,  new_group_participation) }
      it { is_expected.to     be_able_to(:edit,    group_participation) }
      it { is_expected.to     be_able_to(:edit_stage, group_participation) }
      it { is_expected.to     be_able_to(:update,  group_participation) }
      it { is_expected.to     be_able_to(:destroy, group_participation) }
    end

    context 'an admin of the participating group' do
      let(:group) { participant_group }
      let(:group_role_class) { Group::Verein::Admin }

      it { is_expected.to     be_able_to(:show,    group_participation) }
      it { is_expected.to     be_able_to(:new,     new_group_participation) }
      it { is_expected.to     be_able_to(:create,  new_group_participation) }
      it { is_expected.to     be_able_to(:edit,    group_participation) }
      it { is_expected.to     be_able_to(:edit_stage, group_participation) }
      it { is_expected.to     be_able_to(:update,  group_participation) }
      it { is_expected.to     be_able_to(:destroy, group_participation) }
    end

    context 'an admin of another group' do
      let(:group) { other_group }
      let(:group_role_class) { Group::Verein::Admin }

      it { is_expected.to_not be_able_to(:show,    group_participation) }
      it { is_expected.to_not be_able_to(:new,     new_group_participation) }
      it { is_expected.to_not be_able_to(:create,  new_group_participation) }
      it { is_expected.to_not be_able_to(:edit,    group_participation) }
      it { is_expected.to_not be_able_to(:edit_stage, group_participation) }
      it { is_expected.to_not be_able_to(:update,  group_participation) }
      it { is_expected.to_not be_able_to(:destroy, group_participation) }
    end
  end

  context 'after the application period' do
    before { travel_to(application_close.succ) }
    after { travel_back }

    context 'a festival organizer' do
      let(:group) { organizer_group }
      let(:group_role_class) { Group::Root::Admin }

      it { is_expected.to     be_able_to(:show,    group_participation) }
      it { is_expected.to     be_able_to(:index,   group_participation.class) }
      it { is_expected.to_not be_able_to(:new,     new_group_participation) }
      it { is_expected.to_not be_able_to(:create,  new_group_participation) }
      it { is_expected.to     be_able_to(:edit,    group_participation) }
      it { is_expected.to     be_able_to(:edit_stage, group_participation) }
      it { is_expected.to     be_able_to(:update,  group_participation) }
      it { is_expected.to     be_able_to(:destroy, group_participation) }
    end

    context 'an admin of the participating group' do
      let(:group) { participant_group }
      let(:group_role_class) { Group::Verein::Admin }

      it { is_expected.to     be_able_to(:show,    group_participation) }
      it { is_expected.to_not be_able_to(:new,     new_group_participation) }
      it { is_expected.to_not be_able_to(:create,  new_group_participation) }
      it { is_expected.to_not be_able_to(:edit,    group_participation) }
      it { is_expected.to_not be_able_to(:edit_stage, group_participation) }
      it { is_expected.to_not be_able_to(:update,  group_participation) }
      it { is_expected.to_not be_able_to(:destroy, group_participation) }
    end

    context 'an admin of another group' do
      let(:group) { other_group }
      let(:group_role_class) { Group::Verein::Admin }

      it { is_expected.to_not be_able_to(:show,    group_participation) }
      it { is_expected.to_not be_able_to(:new,     new_group_participation) }
      it { is_expected.to_not be_able_to(:create,  new_group_participation) }
      it { is_expected.to_not be_able_to(:edit,    group_participation) }
      it { is_expected.to_not be_able_to(:edit_stage, group_participation) }
      it { is_expected.to_not be_able_to(:update,  group_participation) }
      it { is_expected.to_not be_able_to(:destroy, group_participation) }
    end
  end
end
