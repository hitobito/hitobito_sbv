# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'
require 'benchmark'

N = 1_000

FETCH_YEARS_TIME = 0.1

# describe 'VeteranYears', performance: true do
describe 'VeteranYears' do
  let(:group) { groups(:mitglieder_mg_aarberg) }
  let(:person) { people(:member) }

  before :each do
    Role.create!(person: person, group: group, created_at: 20.years.ago, deleted_at: 17.years.ago, type: 'Group::VereinMitglieder::Mitglied')
    Role.create!(person: person, group: group, created_at: 15.years.ago, deleted_at: 13.years.ago, type: 'Group::VereinMitglieder::Mitglied')
    Role.create!(person: person, group: group, created_at: 10.years.ago, deleted_at:  7.years.ago, type: 'Group::VereinMitglieder::Mitglied')
    Role.create!(person: person, group: group, created_at:  5.years.ago, deleted_at:  3.years.ago, type: 'Group::VereinMitglieder::Mitglied')
    person.save # trigger callback to update year-cache
  end

  def measure(max_time, &block)
    ms = Benchmark.measure do |x|
      N.times(&block)
    end

    expect(ms.total).to be < max_time
  end

  it 'load active years' do
    measure(FETCH_YEARS_TIME) do
      expect(person.active_years).to be == 10
    end
  end

  it 'load prognostic active years' do
    measure(FETCH_YEARS_TIME) do
      expect(person.prognostic_active_years).to be == 11
    end
  end

end
