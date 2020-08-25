# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Events::GroupParticipationsController do
  include ActiveSupport::Testing::TimeHelpers

  let(:group)    { organizer_group }

  let(:organizer_group)   { groups(:hauptgruppe_1) }
  let(:participant_group) { groups(:musikgesellschaft_alterswil) }
  let(:other_group)       { groups(:musikverband_hastdutoene) }

  let(:festival) { Fabricate(:festival, name: 'Fäschti-Wal', groups: [group]) }

  context 'index' do
    let(:admin) { people(:admin) }

    before do
      sign_in(admin)
    end

    it 'exports xlsx' do
      get :index, params: { group_id: group.id, event_id: festival.id }, format: :xlsx
      expect(flash[:notice]).to eq 'Export wird im Hintergrund gestartet und nach Fertigstellung heruntergeladen.'
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to group_event_group_participations_path(group, festival, returning: true)
    end

    it 'exports csv' do
      get :index, params: { group_id: group.id, event_id: festival.id }, format: :csv
      expect(flash[:notice]).to eq 'Export wird im Hintergrund gestartet und nach Fertigstellung heruntergeladen.'
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to group_event_group_participations_path(group, festival, returning: true)
    end
  end

  context 'edit' do
    let(:entry) do
      Fabricate(:group_participation, group: participant_group, event: festival)
    end

    context 'during the application period' do
      before do
        travel_to(festival.application_opening_at.succ)
        sign_in(person)
      end
      after { travel_back }

      context 'a festival organizer' do
        let(:person) do
          people(:admin).tap do |person|
            person.roles << Group::Root::Admin.new(group: organizer_group)
          end
        end

        it 'can change the application' do
          get :edit, params: { group_id: organizer_group.id, event_id: festival.id, id: entry.id }
          expect(response).to have_http_status(:success)
        end
      end

      context 'an admin of the participating group' do
        let(:person) { people(:leader) }

        it 'can change the application' do
          get :edit, params: { group_id: organizer_group.id, event_id: festival.id, id: entry.id }
          expect(response).to have_http_status(:success)
        end
      end

      context 'an admin of another group' do
        let(:person) do
          people(:member).tap do |person|
            person.roles << Group::Verein::Admin.new(group: other_group)
          end
        end

        it 'cannot change the application' do
          expect do
            get :edit, params: { group_id: organizer_group.id, event_id: festival.id, id: entry.id }
          end.to raise_exception CanCan::AccessDenied
        end
      end
    end

    context 'after the application period' do
      before do
        travel_to(festival.application_closing_at.succ)
        sign_in(person)
      end
      after { travel_back }

      context 'a festival organizer' do
        let(:person) do
          people(:admin).tap do |person|
            person.roles << Group::Root::Admin.new(group: organizer_group)
          end
        end

        it 'can change the application' do
          get :edit, params: { group_id: organizer_group.id, event_id: festival.id, id: entry.id }
          expect(response).to have_http_status(:success)
        end
      end

      context 'an admin of the participating group' do
        let(:person) { people(:leader) }

        it 'cannot change the application anymore' do
          expect do
            get :edit, params: { group_id: organizer_group.id, event_id: festival.id, id: entry.id }
          end.to raise_exception CanCan::AccessDenied
        end
      end

      context 'an admin of another group' do
        let(:person) do
          people(:member).tap do |person|
            person.roles << Group::Verein::Admin.new(group: other_group)
          end
        end

        it 'cannot change the application' do
          expect do
            get :edit, params: { group_id: organizer_group.id, event_id: festival.id, id: entry.id }
          end.to raise_exception CanCan::AccessDenied
        end
      end
    end
  end
end
