#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe SongCountsController do
  let(:group) { Fabricate(Group::Regionalverband.name.to_sym) }
  let(:verein) { Fabricate(Group::Verein.name.to_sym, parent: group, name: "Harmonie Sursee") }

  context "index" do
    let(:admin) { people(:admin) }

    before do
      Fabricate(Group::Verein::SuisaAdmin.name.to_sym, group: verein, person: admin)
      Fabricate(Group::Regionalverband::SuisaAdmin.name.to_sym, group: group, person: admin)
      sign_in(admin)
    end

    it "exports csv" do
      get :index, params: {group_id: verein}, format: :csv
      # rubocop:todo Layout/LineLength
      expect(flash[:notice]).to eq "Export wird im Hintergrund gestartet und nach Fertigstellung heruntergeladen."
      # rubocop:enable Layout/LineLength
      expect(response).to redirect_to group_concerts_path(verein)
    end

    it "exports xlsx" do
      get :index, params: {group_id: group}, format: :xlsx
      # rubocop:todo Layout/LineLength
      expect(flash[:notice]).to eq "Export wird im Hintergrund gestartet und nach Fertigstellung heruntergeladen."
      # rubocop:enable Layout/LineLength
      expect(response).to redirect_to group_song_censuses_path(group)
    end
  end
end
