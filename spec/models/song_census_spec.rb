# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe SongCensus do
  include ActiveSupport::Testing::TimeHelpers

  describe '.last' do
    subject { described_class.last }

    it { is_expected.to eq(song_censuses(:two_o_18)) }
  end

  describe '.current' do
    subject { described_class.current }

    it 'should eq 2017 census' do
      travel_to Time.new(2018, 01, 01) do
        is_expected.to eq(song_censuses(:two_o_17))
      end
    end
  end

  describe 'defaults' do

    it { is_expected.to have_attributes(year: Time.zone.today.year )}

    context 'without census-settings' do
      before do
        expect(Settings).to receive(:census).at_least(:once).and_return(nil)
      end

      it 'leaves finish_at empty' do
        is_expected.to have_attributes(finish_at: nil)
      end

      it 'uses the current year to name the period' do
        is_expected.to have_attributes(start_at: Time.zone.today )
      end
    end

    context 'with census-settings' do
      before do
        census_settings = double
        allow(census_settings).to receive(:default_finish_month).and_return(12)
        allow(census_settings).to receive(:default_finish_day).and_return(24)

        expect(Settings).to receive(:census).at_least(:once).and_return(census_settings)
      end

      it 'uses the current year to name the period' do
        travel_to Time.new(2018, 12, 20) do
          is_expected.to have_attributes(year: 2018)
        end
      end

      it 'uses the current year for the finish-date if possible' do
        travel_to Time.new(2018, 12, 20) do
          is_expected.to have_attributes(finish_at: Date.new(2018, 12, 24))
        end
      end


      it 'uses the next year to name the period' do
        travel_to Time.new(2018, 12, 25) do
          is_expected.to have_attributes(finish_at: Date.new(2019, 12, 24))
        end
      end

      it 'uses the next year for the finish-date if needed' do
        travel_to Time.new(2018, 12, 25) do
          is_expected.to have_attributes(year: 2019)
        end
      end
    end
  end
end
