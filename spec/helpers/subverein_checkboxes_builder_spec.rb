# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe SubvereinCheckboxesBuilder do
  describe "#vereine_nesting" do
    let(:root) { groups(:bernischer_kantonal_musikverband) }
    let(:vereine) { Group.where(id: [groups(:musikgesellschaft_aarberg).id]) }

    subject { described_class.new(root, nil) }

    it "creates nesting" do
      nesting = subject.send(:vereine_nesting)
      expected = {}
      expected[root] = {}
      regionalverband = groups(:regionalverband_mittleres_seeland)
      expected[root][regionalverband] = {}
      expected[root][regionalverband][regionalverband] = vereine
      expect(nesting).to eq(expected)
    end
  end
end
