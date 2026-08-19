# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe RoleDecorator, :draper_with_helpers do
  let(:decorator) { described_class.new(role) }

  context "Mitglied with instrument" do
    let(:role) { roles(:member) }

    before { role.update!(instrument: "trompete", label: nil) }

    it "includes the instrument in for_aside" do
      expect(decorator.for_aside).to include("Trompete")
      expect(decorator.class.ancestors).to include(Sbv::RoleDecorator)
    end

    it "includes the instrument in for_history" do
      expect(decorator.for_history).to include("Trompete")
    end
  end

  context "non-Mitglied with label" do
    let(:role) { roles(:leader) }

    before { role.update!(label: "Dirigentin") }

    it "keeps the label in for_aside" do
      expect(decorator.for_aside).to include("Dirigentin")
    end
  end
end
