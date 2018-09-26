# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe ConcertsController do
  let(:group)  { Fabricate(Group::Regionalverband.name.to_sym) }
  let(:verein) { Fabricate(Group::Verein.name.to_sym, parent: group, name: 'Harmonie Sursee') }
  let(:admin)  { people(:suisa_admin) }

  before do
    sign_in(admin)
  end

  context 'new' do
    it 'sets recently played songs as preselection' do
      allow_any_instance_of(Group::Verein).to receive(:last_played_song_ids).and_return([1, 3])

      get :new, group_id: admin.primary_group

      entry = assigns(:concert)
      expect(entry.song_counts.length).to be 2
      expect(entry.song_counts.map(&:song_id)).to include(1, 3)
      entry.song_counts.each { |sc| expect(sc.count).to eq 0 }
    end
  end

end
