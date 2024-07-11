#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe SongCensusMailer do
  before do
    SeedFu.quiet = true
    SeedFu.seed [HitobitoSbv::Wagon.root.join("db", "seeds")]
  end

  let(:person) { people(:suisa_admin) }
  let(:group) { groups(:musikgesellschaft_alterswil) }

  subject { mail }

  describe "#reminder" do
    context "includes content" do
      let(:mail) { SongCensusMailer.reminder(person, group) }

      its(:subject) { is_expected.to == "Meldeliste ausfüllen!" }
      its(:from) { is_expected.to == ["noreply@localhost"] }
      its(:to) { is_expected.to == [person.email] }
      its(:body) { is_expected.to =~ /Hallo Suisa Boy/ }
      its(:body) { is_expected.to =~ /die Meldeliste für den Verein 'Musikgesellschaft Alterswil'/ }
      its(:body) { is_expected.to =~ /Dein Hauptgruppe/ }
    end
  end
end
