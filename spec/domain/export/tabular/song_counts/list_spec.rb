#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'
require 'csv'

describe Export::Tabular::SongCounts::List do

  let(:data) { Export::Tabular::SongCounts::List.csv(list) }
  let(:csv) { CSV.parse(data, headers: true, col_sep: Settings.csv.separator) }

  subject { csv }

  context 'verein' do

    let(:list) { groups(:musikgesellschaft_aarberg_19).song_counts }

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

  context 'group' do

    let(:list) { groups(:hauptgruppe_1).song_counts }

    its(:headers) do
      should == ['Anzahl', 'Titel', 'Komponist', 'Arrangeur', 'Verein', 'Vereins ID']
    end

    it 'has 3 items' do
      expect(subject.size).to eq(3)
    end

    context 'first row' do

      subject { csv[0] }

      its(['Anzahl']) { should == '12' }
      its(['Titel']) { should == 'Fortunate Son' }
      its(['Komponist']) { should == 'John Fogerty' }
      its(['Arrangeur']) { should == 'Creedence Clearwater Revival' }
      its(['Verein']) { should == 'Musikgesellschaft Aarberg' }
      its(['Vereins ID']) { should == groups(:musikgesellschaft_aarberg_19).id.to_s }
    end

    context 'second row' do

      subject { csv[1] }

      its(['Anzahl']) { should == '8' }
      its(['Titel']) { should == "Papa Was a Rollin' Stone" }
      its(['Komponist']) { should == 'Barrett Strong / Norman Whitfield' }
      its(['Arrangeur']) { should == 'The Temptations' }
      its(['Verein']) { should == 'Musikgesellschaft Aarberg' }
      its(['Vereins ID']) { should == groups(:musikgesellschaft_aarberg_19).id.to_s }
    end

    context 'third row' do

      subject { csv[2] }

      its(['Anzahl']) { should == '2' }
      its(['Titel']) { should == 'Material Girl' }
      its(['Komponist']) { should == 'Peter Brown / Robert Rans' }
      its(['Arrangeur']) { should == 'Madonna' }
      its(['Verein']) { should == 'Musikgesellschaft Alterswil' }
      its(['Vereins ID']) { should == groups(:musikgesellschaft_alterswil).id.to_s }
    end
  end
end
