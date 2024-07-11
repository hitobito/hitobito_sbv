#  Copyright (c) 2023, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"
describe Group::Mover do
  let(:move) { Group::Mover.new(group) }

  context "moving a Verein to a different Regionalverband in the same Mitgliederverband" do
    let(:group) { groups(:musikgesellschaft_aarberg) }
    let(:target) { Fabricate(Group::Regionalverband.name) }

    context "moves group" do
      subject { group.reload }

      before { move.perform(target) }

      its(:parent) { is_expected.to eq target }
      its(:layer_group_id) { is_expected.to eq group.id }

      it "nested set should still be valid" do
        expect(Group).to be_valid
      end

      it "keeps layer group id of Verein children" do
        expect(groups(:vorstand_mg_aarberg).layer_group_id).to eq(group.id)
      end
    end
  end
end
