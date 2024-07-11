# frozen_string_literal: true

#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Event::Festival do
  let(:festival) { events(:festival) }
  let(:group) { groups(:musikgesellschaft_aarberg) }

  it "has prerequisites" do
    do_not_participate(group, festival)

    expect(described_class.upcoming).to be_one
  end

  it "knows which events are participatable" do
    do_not_participate(group, festival)

    list = described_class.participatable(group)

    expect(list).to be_one
  end

  it "does not count events as participatable if already applied" do
    participate(group, festival)

    list = described_class.participatable(group)

    expect(list).to be_empty
  end

  it "knows events a group has already applied to" do
    participate(group, festival)

    relation = described_class.participation_by(group)

    expect(relation.to_a).to eql [festival]
  end

  private

  def participate(group, event)
    Event::GroupParticipation.create(
      group_id: group.id,
      event_id: festival.id
    )
  end

  def do_not_participate(group, event)
    count = Event::GroupParticipation.where(
      group_id: group.id,
      event_id: festival.id
    ).count

    expect(count).to be 0
  end
end
