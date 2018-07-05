#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe SongCountsController do
  let(:group)  { Fabricate(Group::Regionalverband.name.to_sym) }
  let(:verein) { Fabricate(Group::Verein.name.to_sym, parent: group, name: 'Harmonie Sursee') }

  context 'index' do
    let(:admin) { people(:admin) }

    before do
      Fabricate(Group::Verein::SuisaAdmin.name.to_sym, group: verein, person: admin)
      Fabricate(Group::Regionalverband::SuisaAdmin.name.to_sym, group: group, person: admin)
      sign_in(admin)
    end

    it 'exports csv' do
      get :index, group_id: verein, format: :csv
      expect(response.header['Content-Disposition']).
        to match(/Werkmeldung-harmonie_sursee-\d{4}.csv/)

      expect(response.content_type).to eq('text/csv')
    end

    it 'exports xlsx' do
      get :index, group_id: group, format: :xlsx
      expect(response.header['Content-Disposition']).
        to match(/Werkmeldung-\d{4}.xlsx/)

      expect(response.content_type).to eq('application/xlsx')
    end
  end

  context 'submit' do
    let(:admin) { people(:suisa_admin) }

    before do
      sign_in(admin)

      song_counts(:girl_count).update(song_census: nil)
      song_counts(:papa_count).update(verein: admin.primary_group, song_census: nil)
    end

    it 'connects open song-counts to the current song-census' do
      expect do
        post :submit, group_id: admin.primary_group
      end.to change { SongCount.where(song_census: nil).count }.by(-2)
    end

    it 'displays a message about song-count submission' do
      post :submit, group_id: admin.primary_group
      expect(flash[:notice]).to match(/Meldeliste eingereicht/)
    end
  end

end
