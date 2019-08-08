#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe SongCensusMailer do

  before do
    SeedFu.quiet = true
    SeedFu.seed [HitobitoSbv::Wagon.root.join('db', 'seeds')]
  end

  let(:person) { people(:suisa_admin) }
  let(:group)  { groups(:musikgesellschaft_alterswil) }

  subject { mail }

  describe '#reminder' do
    context 'includes content' do
      let(:mail) { SongCensusMailer.reminder(person, group) }

      its(:subject) { should == 'Meldeliste ausfüllen!' }
      its(:from)    { should == ['noreply@localhost'] }
      its(:to)      { should == [person.email] }
      its(:body)    { should =~ /Hallo Suisa Boy/ }
      its(:body)    { should =~ /die Meldeliste für den Verein 'Musikgesellschaft Alterswil'/ }
      its(:body)    { should =~ /Dein Hauptgruppe/ }
    end

  end
end
