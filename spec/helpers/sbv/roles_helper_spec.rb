# frozen_string_literal: true

#  Copyright (c) 2021, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Sbv::RolesHelper do
  describe "#default_language_for_person" do
    let(:group) { groups(:hauptgruppe_1) }

    it "returns group language" do
      group.language = "rm"
      language = default_language_for_person(group)

      expect(language).to eq("rm")
    end
  end
end
