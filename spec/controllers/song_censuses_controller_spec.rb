#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe SongCensusesController do
  let(:group)   { Fabricate(Group::Regionalverband.name.to_sym) }
  let(:verein1) { Fabricate(Group::Verein.name.to_sym, parent: group) }
  let(:verein2) { Fabricate(Group::Verein.name.to_sym, parent: group) }

  context 'index' do
    let(:admin) { people(:admin) }

    before do
      Fabricate(Group::Regionalverband::SuisaAdmin.name.to_sym, group: group, person: admin)
      sign_in(admin)
    end

    it 'shows which groups have submitted a census' do
      get :index, group_id: group.id

      expect(response).to have_http_status(:ok)
    end
  end

  context 'create' do
    let(:admin) { people(:suisa_admin) }

    before do
      sign_in(admin)

      song_counts(:girl_count).update(song_census: nil)
      song_counts(:papa_count).update(verein: admin.primary_group, song_census: nil)
    end

    it 'connects open song-counts to the current song-census' do
      expect do
        post :create, group_id: admin.primary_group
      end.to change { SongCount.where(song_census: nil).count }.by(-2)
    end
  end

  context 'remind' do
    let(:song_census)  { song_censuses(:two_o_18) }

    before do
      sign_in(people(:suisa_admin))

      2.times { Fabricate(Group::Verein::SuisaAdmin.name.to_sym, group: verein1)}
      Fabricate(Group::Verein::SuisaAdmin.name.to_sym, group: verein2)
    end

    it 'reminds suisa_admins' do
      ref = @request.env['HTTP_REFERER'] = group_song_censuses_path(group, song_census)

      expect do
        post :remind, group_id: group, song_census_id: song_census
      end.to change { ActionMailer::Base.deliveries.size }.by 3

      is_expected.to redirect_to(ref)
    end
  end
end
