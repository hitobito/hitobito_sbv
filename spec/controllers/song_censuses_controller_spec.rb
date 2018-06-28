#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe SongCensusesController do
  context 'remind' do
    let(:group)   { Fabricate(Group::Regionalverband.name.to_sym) }
    let(:verein1) { Fabricate(Group::Verein.name.to_sym, parent: group) }
    let(:verein2) { Fabricate(Group::Verein.name.to_sym, parent: group) }
    let(:song_census)  { song_censuses(:two_o_18) }

    before do
      sign_in(people(:suisa_admin))

      2.times { Fabricate(Group::Verein::SuisaAdmin.name.to_sym, group: verein1)}
      Fabricate(Group::Verein::SuisaAdmin.name.to_sym, group: verein1)
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
