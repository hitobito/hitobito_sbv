#  Copyright (c) 2018-2024, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe VeteranYears do
  include ActiveSupport::Testing::TimeHelpers
  let(:empty_veteran_years) { described_class::NULL }

  context "with the new algorithm that has been ratified on 2020-11-14 (VL-Sitzung), it" do
    before do
      travel_to Date.new(2020, 7, 31)
    end

    it "has an abstract example" do
      first = described_class.new(1979, 1986)
      second = described_class.new(1994, 2005)
      third = described_class.new(2017, 2020)

      expect(first.years).to be == 8
      expect(second.years).to be == 12
      expect(third.years).to be == 3

      expect((first + second + third).years).to be == 23
    end

    it "has a concrete bug-report" do
      expect([
        described_class.new(1951, 1956),
        described_class.new(1956, 1959),
        described_class.new(1959, 1964),
        described_class.new(1964, 1970),
        described_class.new(1970, 1981),
        described_class.new(1981, 2020)
      ].sum(empty_veteran_years).years).to be == 69
    end

    it "counts completed years in the past" do
      subject = [
        described_class.new(2018, 2020)
      ].sum(empty_veteran_years)

      expect(subject.send(:year_list)).to match_array [2018, 2019, 2020]
      expect(subject.years).to be == 2
    end

    it "counts only years with membership" do
      subject = [
        described_class.new(2018, 2018),
        described_class.new(2018, 2019)
      ].sum(empty_veteran_years)

      expect(subject.send(:year_list)).to match_array [2018, 2019]
      expect(subject.years).to be == 2
    end

    it "counts multiple durations in one year only once" do
      subject = [
        described_class.new(2018, 2018),
        described_class.new(2018, 2020)
      ].sum(empty_veteran_years)

      expect(subject.send(:year_list)).to match_array [2018, 2019, 2020]
      expect(subject.years).to be == 2
    end

    it "counts years which have an short interruption fully" do
      subject = [
        described_class.new(2018, 2018),
        described_class.new(2018, 2020)
      ].sum(empty_veteran_years)

      expect(subject.send(:year_list)).to match_array [2018, 2019, 2020]
      expect(subject.years).to be == 2
    end

    it "does not count completely omitted years" do
      subject = [
        described_class.new(2018, 2018),
        described_class.new(2020, 2020)
      ].sum(empty_veteran_years)

      expect(subject.send(:year_list)).to match_array [2018, 2020]
      expect(subject.years).to be == 1
    end
  end

  context "has some helper methods to" do
    it "sort" do
      first = described_class.new(1978, 1981)
      second = described_class.new(1983, 2010)
      third = described_class.new(2012, 2013)

      expect([third, second, first].sort).to be == [first, second, third]
    end

    describe "add, which" do
      let(:first) { described_class.new(1978, 1981) }
      let(:second) { described_class.new(1983, 2010) }

      subject { first + second }

      it "returns a new VeteranYears-Object" do
        is_expected.to be_a described_class
      end

      it "uses the earliest start year" do
        expect(subject.start_year).to be == 1978
      end

      it "uses the latest end_year" do
        expect(subject.end_year).to be == 2010
      end

      it "calculates gaps" do
        expect(subject.passive_years).to be == [1982]
      end

      it "combines gaps" do
        first = described_class.new(1978, 2010, [1982])
        second = described_class.new(2010, 2015, [2013])
        result = first + second

        expect(result.passive_years).to be == [1982, 2013]
      end

      it "can be used to sum up an array" do
        expect([first, second].sum(empty_veteran_years)).to be_a described_class
      end
    end
  end
end
