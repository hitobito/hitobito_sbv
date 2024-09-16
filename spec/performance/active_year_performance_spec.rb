#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"
require "benchmark"

N = 1_000

FETCH_YEARS_TIME = 0.1

describe "VeteranYears", performance: true do
  let(:group) { groups(:mitglieder_mg_aarberg) }
  let(:person) { people(:member) }

  before do
    person.roles.each { |role| role.really_destroy! }
    Role.create!(person: person, group: group, start_on: 20.years.ago, end_on: 17.years.ago, type: "Group::VereinMitglieder::Mitglied")
    Role.create!(person: person, group: group, start_on: 15.years.ago, end_on: 13.years.ago, type: "Group::VereinMitglieder::Mitglied")
    Role.create!(person: person, group: group, start_on: 10.years.ago, end_on: 7.years.ago, type: "Group::VereinMitglieder::Mitglied")
    Role.create!(person: person, group: group, start_on: 5.years.ago, end_on: 3.years.ago, type: "Group::VereinMitglieder::Mitglied")
    Role.create!(person: person, group: group, start_on: 1.year.ago, end_on: nil, type: "Group::VereinMitglieder::Mitglied")
  end

  def measure(max_time, &block)
    ms = Benchmark.measure do |x|
      N.times(&block)
    end

    expect(ms.total).to be < max_time
  end

  it "load active years" do
    measure(FETCH_YEARS_TIME) do
      expect(person.active_years).to be == 15
    end
  end

  it "load prognostic active years" do
    measure(FETCH_YEARS_TIME) do
      expect(person.prognostic_active_years).to be == 16
    end
  end
end
