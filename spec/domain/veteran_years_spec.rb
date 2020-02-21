#  Copyright (c) 2018-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe VeteranYears do
  include ActiveSupport::Testing::TimeHelpers

  it 'counts full duration if continuous' do
    expect(described_class.new(1978, 2013).years).to be == 35
  end

  it 'counts full duration if break was not a full year' do
    first = described_class.new(1978, 2011)
    second = described_class.new(2012, 2013)

    expect((first + second).years).to be == 35
  end

  it 'counts full duration if breaks were not full years' do
    first = described_class.new(1978, 1981)
    second = described_class.new(1982, 2011)
    third = described_class.new(2012, 2013)

    expect((first + second + third).years).to be == 35
  end

  it 'does not count a break of over a year' do
    first = described_class.new(1978, 2010)
    second = described_class.new(2012, 2013)

    expect((first + second).years).to be == 33
  end

  it 'does not count several breaks of over a year' do
    first = described_class.new(1978, 1981)
    second = described_class.new(1983, 2010)
    third = described_class.new(2012, 2013)

    expect((first + second + third).years).to be == 31
  end

  it 'does count the current year as full year' do
    travel_to Date.new(2020, 02, 01) do
      expect(described_class.new(2010, 2020).years).to be == 11
    end
  end

  context 'has some helper methods to' do
    it 'sort' do
      first = described_class.new(1978, 1981)
      second = described_class.new(1983, 2010)
      third = described_class.new(2012, 2013)

      expect([third, second, first].sort).to be == [first, second, third]
    end

    describe 'add, which' do
      let(:first) { described_class.new(1978, 1981) }
      let(:second) { described_class.new(1983, 2010) }
      let(:result) { first + second }

      it 'returns a new VeteranYears-Object' do
        expect(result).to be_a described_class
      end

      it 'uses the earliest start year' do
        expect(result.start_year).to be == 1978
      end

      it 'uses the latest end_year' do
        expect(result.end_year).to be == 2010
      end

      it 'calculates gaps' do
        expect(result.passive_years).to be == [1982]
      end

      it 'combines gaps' do
        first = described_class.new(1978, 2010, [1982])
        second = described_class.new(2010, 2015, [2013])
        result = first + second

        expect(result.passive_years).to be == [1982, 2013]
      end

      it 'can be used to sum up an array' do
        expect([first, second].sum).to be_a described_class
      end
    end
  end

end
