# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Events::GroupParticipationsController do
  let(:group)    { groups(:hauptgruppe_1) }
  let(:festival) { Fabricate(:festival, name: 'Fäschti-Wal', groups: [group], type: 'Event::Festival') }

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
end
