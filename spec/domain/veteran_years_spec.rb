require 'spec_helper'

describe VeteranYears do

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

end
