#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe SongCensus do
  include ActiveSupport::Testing::TimeHelpers

  describe ".last" do
    subject { described_class.last }

    it { is_expected.to eq(song_censuses(:two_o_18)) }
  end

  describe ".current" do
    subject { described_class.current }

    it "should eq 2017 census" do
      travel_to Time.zone.local(2018, 1, 1) do
        is_expected.to eq(song_censuses(:two_o_17))
      end
    end
  end

  describe "defaults" do
    include ActiveSupport::Testing::TimeHelpers

    it "sets defaults to this year when current time is before december " do
      travel_to("2019-03-05 10:00:00") do
        is_expected.to have_attributes(year: 2019, finish_at: Date.new(2019, 11, 30))
      end
    end

    it "sets defaults to next year when current time is past december" do
      travel_to("2019-12-01 10:00:00") do
        is_expected.to have_attributes(year: 2020, finish_at: Date.new(2020, 11, 30))
      end
    end

    context "without census-settings" do
      before do
        expect(Settings).to receive(:census).at_least(:once).and_return(nil)
      end

      it "leaves finish_at empty" do
        is_expected.to have_attributes(finish_at: nil)
      end

      it "uses the current year to name the period" do
        is_expected.to have_attributes(start_at: Time.zone.today)
      end
    end

    context "with census-settings" do
      before do
        census_settings = double
        allow(census_settings).to receive(:default_finish_month).and_return(12)
        allow(census_settings).to receive(:default_finish_day).and_return(24)

        expect(Settings).to receive(:census).at_least(:once).and_return(census_settings)
      end

      it "uses the current year to name the period" do
        travel_to Time.zone.local(2018, 12, 20) do
          is_expected.to have_attributes(year: 2018)
        end
      end

      it "uses the current year for the finish-date if possible" do
        travel_to Time.zone.local(2018, 12, 20) do
          is_expected.to have_attributes(finish_at: Date.new(2018, 12, 24))
        end
      end

      it "uses the next year to name the period" do
        travel_to Time.zone.local(2018, 12, 25) do
          is_expected.to have_attributes(finish_at: Date.new(2019, 12, 24))
        end
      end

      it "uses the next year for the finish-date if needed" do
        travel_to Time.zone.local(2018, 12, 25) do
          is_expected.to have_attributes(year: 2019)
        end
      end
    end
  end
end
