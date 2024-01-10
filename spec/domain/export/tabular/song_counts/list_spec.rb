# frozen_string_literal: true

#  Copyright (c) 2012-2024, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'
require 'csv'

describe Export::Tabular::SongCounts::List do

  let(:data) { Export::Tabular::SongCounts::List.csv(list) }
  let(:data_without_bom) { data.gsub(Regexp.new("^#{Export::Csv::UTF8_BOM}"), '') }
  let(:csv)  { CSV.parse(data_without_bom, headers: true, col_sep: Settings.csv.separator) }
  let(:sorted_csv) { csv.sort_by { |r| [r['SUISA-ID'], r['Titel']] } }

  subject { csv }

  context 'verein' do

    let(:list) { groups(:musikgesellschaft_aarberg).song_counts.order(:concert_id) }

    its(:headers) do
      should == ['Anzahl', 'Titel', 'Komponist', 'Arrangeur', 'Verlag', 'SUISA-ID', 'Verein', 'Vereins ID']
    end

    it 'has 2 items' do
      expect(subject.size).to eq(2)
    end

    context 'first row' do

      subject { sorted_csv[0] }

      its(['Anzahl']) { should == '12' }
      its(['Titel']) { should == 'Fortunate Son' }
      its(['Komponist']) { should == 'John Fogerty' }
      its(['Arrangeur']) { should == 'Creedence Clearwater Revival' }
      its(['Verlag']) { should == 'Fantasy' }
      its(['SUISA-ID']) { should == '12345' }
      its(['Verein']) { should == 'Musikgesellschaft Aarberg' }
      its(['Vereins ID']) { should == groups(:musikgesellschaft_aarberg).id.to_s }
    end

    context 'second row' do

      subject { sorted_csv[1] }

      its(['Anzahl']) { should == '8' }
      its(['Titel']) { should == "Papa Was a Rollin' Stone" }
      its(['Komponist']) { should == 'Barrett Strong / Norman Whitfield' }
      its(['Arrangeur']) { should == 'The Temptations' }
      its(['Verlag']) { should == 'Motown' }
      its(['SUISA-ID']) { should == '23456' }
      its(['Verein']) { should == 'Musikgesellschaft Aarberg' }
      its(['Vereins ID']) { should == groups(:musikgesellschaft_aarberg).id.to_s }
    end
  end

  context 'group' do

    let(:list) { groups(:hauptgruppe_1).song_counts.order(:concert_id) }

    its(:headers) do
      should == ['Anzahl', 'Titel', 'Komponist', 'Arrangeur', 'Verlag', 'SUISA-ID', 'Verein und Ort']
    end

    it 'has 4 items' do
      expect(subject.size).to eq(4)
    end

    context 'first row' do

      subject { sorted_csv[0] }

      its(['Anzahl']) { should == '12' }
      its(['Titel']) { should == 'Fortunate Son' }
      its(['Komponist']) { should == 'John Fogerty' }
      its(['Arrangeur']) { should == 'Creedence Clearwater Revival' }
      its(['Verlag']) { should == 'Fantasy' }
      its(['SUISA-ID']) { should == '12345' }
      its(['Verein und Ort']) { should == 'Musikgesellschaft Aarberg, Thiloscheid' }
    end

    context 'second row' do

      subject { sorted_csv[1] }

      its(['Anzahl']) { should == '8' }
      its(['Titel']) { should == "Papa Was a Rollin' Stone" }
      its(['Komponist']) { should == 'Barrett Strong / Norman Whitfield' }
      its(['Arrangeur']) { should == 'The Temptations' }
      its(['Verlag']) { should == 'Motown' }
      its(['SUISA-ID']) { should == '23456' }
      its(['Verein und Ort']) { should == 'Musikgesellschaft Aarberg, Thiloscheid' }
    end

    context 'third row' do

      subject { sorted_csv[2] }

      its(['Anzahl']) { should == '4' }
      its(['Titel']) { should == "Papa Was a Rollin' Stone" }
      its(['Komponist']) { should == 'Barrett Strong / Norman Whitfield' }
      its(['Arrangeur']) { should == 'The Temptations' }
      its(['Verlag']) { should == 'Motown' }
      its(['SUISA-ID']) { should == '23456' }
      its(['Verein und Ort']) { should == 'Musikgesellschaft Alterswil, Nord Boland' }
    end

    context 'fourth row' do

      subject { sorted_csv[3] }

      its(['Anzahl']) { should == '2' }
      its(['Titel']) { should == 'Material Girl' }
      its(['Komponist']) { should == 'Peter Brown / Robert Rans' }
      its(['Arrangeur']) { should == 'Madonna' }
      its(['Verlag']) { should == 'Sire' }
      its(['SUISA-ID']) { should == '34567' }
      its(['Verein und Ort']) { should == 'Musikgesellschaft Alterswil, Nord Boland' }
    end
  end
end
