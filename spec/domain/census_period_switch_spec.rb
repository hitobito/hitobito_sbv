#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe CensusPeriodSwitch do
  include ActiveSupport::Testing::TimeHelpers
  before { travel_to Date.parse('2018-12-01') }
  after  { travel_back }

  subject { described_class.new(old, new) }
  let(:old) { SongCensus.find_by(year: 2018) }
  let(:new) { SongCensus.new(year: 2019) }

  it 'has some assumptions' do
    expect(old.finish_at).to eq Date.parse('2018-10-31')
  end

  it 'finishes the previous census, shifting the finished_at to match reality' do
    expect do
      subject.perform
    end.to change(old, :finish_at).from(Date.parse('2018-10-31')).to(Date.yesterday)
  end

  it 'moves unsubmitted concerts to the new census-period' do
    expect do
      subject.perform
    end.to change { Concert.where(song_census: nil, year: old.year).count }.by(-1)
  end

  it 'locks all submitted concerts' do
    expect do
      subject.perform
    end.to change { old.concerts.where(editable: true).count }.by(-5)
  end

  it 'corrects the year to match the period' do
    expect do
      subject.perform
    end.to change { old.concerts.where(year: old.year).count }.by(1)
  end
end
