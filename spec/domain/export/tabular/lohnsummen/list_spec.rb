# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'
require 'csv'

describe Export::Tabular::Lohnsummen::List do
  let(:data) { Export::Tabular::Lohnsummen::List.csv(list) }
  let(:csv) { CSV.parse(data, headers: true, col_sep: Settings.csv.separator) }

  subject { csv }

  context 'verein' do
    let(:list) { groups(:musikgesellschaft_aarberg).descendants }

    its(:headers) do
      should == ['Verein', 'BUV Lohnsumme', 'NBUV Lohnsumme']
    end

    it 'has 2 items' do
      expect(subject.size).to eq(2)
    end

    context 'first row' do
      subject { csv[0] }

      its(['Verein']) { should == 'Musikgesellschaft Aarberg' }
      its(['BUV Lohnsumme']) { should be 12_345_67 }
      its(['NBUV Lohnsumme']) { should be 12_345_67 }
    end

    context 'second row' do
      subject { csv[1] }

      its(['Verein']) { should == 'Musikgesellschaft Aarberg' }
      its(['BUV Lohnsumme']) { should be 12_345_67 }
      its(['NBUV Lohnsumme']) { should be 12_345_67 }
    end
  end
end
