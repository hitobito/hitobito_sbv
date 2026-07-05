# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe TableDisplays::People::InstrumentColumn do
  subject { described_class.new(ability, model_class: Person, table: table) }

  let(:ability) { Ability.new(people(:admin)) }
  let(:group) { groups(:musikverband_hastdutoene) }
  let(:person) { people(:member) }
  let(:table) { instance_double(StandardTableBuilder, template: template, selected_group: nil) }
  let(:template) { instance_double(ActionView::Base, group: nil, parent: group) }

  before do
    person.roles.find_by(group: group).update!(instrument: "trompete")
  end

  it "resolves instrument from the group context" do
    expect(subject.send(:allowed_value_for, person, :instrument)).to eq "Trompete"
  end

  it "loads descendant group ids only once per column instance" do
    expect(group).to receive(:self_and_descendants).once.and_call_original

    3.times { subject.send(:allowed_value_for, person, :instrument) }
  end
end
