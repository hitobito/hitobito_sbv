#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'
require 'csv'

describe Export::Tabular::SongCounts::List do

  let(:list) { song_censuses(:two_o_18).song_counts }
  let(:data) { Export::Tabular::SongCounts::List.csv(list) }
  let(:csv) { CSV.parse(data, headers: true, col_sep: Settings.csv.separator) }

  subject { csv }

  its(:headers) do
    should == %w(Anzahl Titel Komponist Arrangeur)
  end

  it 'has 2 items' do
    expect(subject.size).to eq(2)
  end

  context 'first row' do

    subject { csv[0] }

    its(['Anzahl']) { should == '12' }
    its(['Titel']) { should == 'Fortunate Son' }
    its(['Komponist']) { should == 'John Fogerty' }
    its(['Arrangeur']) { should == 'Creedence Clearwater Revival' }
  end

  context 'second row' do

    subject { csv[1] }

    its(['Anzahl']) { should == '8' }
    its(['Titel']) { should == "Papa Was a Rollin' Stone" }
    its(['Komponist']) { should == 'Barrett Strong / Norman Whitfield' }
    its(['Arrangeur']) { should == 'The Temptations' }
  end
end
