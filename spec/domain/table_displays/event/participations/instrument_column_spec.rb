# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe TableDisplays::Event::Participations::InstrumentColumn do
  subject { described_class.new(ability, model_class: Event::Participation, table: table) }

  let(:ability) { Ability.new(people(:admin)) }
  let(:group) { groups(:musikverband_hastdutoene) }
  let(:table) { instance_double(StandardTableBuilder, template: template, selected_group: nil) }
  let(:template) { instance_double(ActionView::Base, group: group) }
  let(:participation) { instance_double(Event::Participation, participant: person) }
  let(:person) { people(:member) }

  before do
    person.roles.find_by(group: group).update!(instrument: "trompete")
  end

  it "is not sortable because instrument is stored on roles, not people" do
    expect(subject.sort_by("participant.instrument")).to be_nil
  end

  it "uses the role instrument label" do
    expect(subject.label("participant.instrument")).to eq Role.human_attribute_name(:instrument)
  end

  it "resolves instrument from the export group context" do
    expect(subject.send(:instrument_for, participation)).to eq "Trompete"
  end

  it "loads descendant group ids only once per column instance" do
    expect(group).to receive(:self_and_descendants).once.and_call_original

    3.times { subject.send(:instrument_for, participation) }
  end
end

describe Event::ParticipationsController do
  subject(:controller) { described_class.new }

  let(:person) { people(:admin) }
  let(:event) { events(:top_course) }

  before do
    TableDisplay.for(person, Event::Participation).update!(selected: ["participant.instrument"])
    allow(controller).to receive(:current_person).and_return(person)
    allow(controller).to receive(:filter_entries)
      .and_return(Event::Participation.where(event: event).includes(event: :questions))
  end

  it "does not register participant.instrument as sortable" do
    mappings = controller.send(:sort_mappings_with_indifferent_access)

    expect(mappings).not_to have_key("participant.instrument")
    expect(controller.send(:sortable?, "participant.instrument")).to be false
  end
end
