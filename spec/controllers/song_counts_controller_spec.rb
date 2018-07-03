#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe SongCountsController do
  let(:group)  { Fabricate(Group::Regionalverband.name.to_sym) }
  let(:verein) { Fabricate(Group::Verein.name.to_sym, parent: group) }

  context 'index' do
    let(:admin) { people(:admin) }

    before do
      Fabricate(Group::Verein::SuisaAdmin.name.to_sym, group: verein, person: admin)
      sign_in(admin)
    end

    it 'exports csv' do
      get :index, group_id: verein.id, format: :csv
      expect(response.header['Content-Disposition']).to match(/Werkmeldung-\d{4}.csv/)
      expect(response.content_type).to eq('text/csv')
    end

    it 'exports xlsx' do
      get :index, group_id: verein.id, format: :xlsx
      expect(response.header['Content-Disposition']).to match(/Werkmeldung-\d{4}.xlsx/)
      expect(response.content_type).to eq('application/xlsx')
    end
  end
end
