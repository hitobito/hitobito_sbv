# frozen_string_literal: true

#  Copyright (c) 2021, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Sbv::RolesHelper do
  describe "#role_type_class" do
    let(:group) { groups(:musikverband_hastdutoene) }
    let(:entry) { Role.new(group: group) }

    it "uses the group standard role when entry has no type yet" do
      expect(role_type_class(entry, group)).to eq Group::VereinMitglieder::Mitglied
    end
  end

  describe "#mitglied_role_type?" do
    it "is true for mitglied role types" do
      expect(mitglied_role_type?(Group::VereinMitglieder::Mitglied)).to be true
    end

    it "is false for other role types" do
      expect(mitglied_role_type?(Group::Verein::Admin)).to be false
    end
  end

  describe "#default_language_for_person" do
    let(:group) { groups(:hauptgruppe_1) }

    it "returns group language" do
      group.language = "rm"
      language = default_language_for_person(group)

      expect(language).to eq("rm")
    end
  end
end
