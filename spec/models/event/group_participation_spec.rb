#  Copyright (c) 2019-2024, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Event::GroupParticipation do
  context "is a state-machine which" do
    subject do
      described_class.create(
        event: events(:festival),
        group: groups(:musikgesellschaft_aarberg)
      )
    end

    it { is_expected.to have_state(:opened).on(:primary) }
    it { is_expected.to allow_event(:progress).on(:primary) }
    it { is_expected.to allow_event(:progress).on(:secondary) }

    it "has defined states on primary" do
      actual_states = subject.aasm(:primary).states.map(&:name)
      expected_states = [
        :opened,
        :joint_participation_selected,
        :primary_group_selected,
        :music_style_selected,
        :music_type_and_level_selected,
        :parade_music_selected
      ]

      expect(actual_states).to match_array(expected_states) # match items
      expect(actual_states).to eq(expected_states) # match items and order
    end

    it "has defined states on secondary" do
      actual_states = subject.aasm(:secondary).states.map(&:name)
      expected_states = [
        :not_present,
        :opened
      ]

      expect(actual_states).to match_array(expected_states) # match items
      expect(actual_states).to eq(expected_states) # match items and order
    end

    # more state-specs?
    # it { is_expected.to allow_event(:select_music_type) }
    # it { is_expected.to have_state(:completed) }
  end

  context "validates" do
    context "secondary_group_id" do
      subject do
        described_class.new(
          event: events(:festival),
          group: groups(:musikgesellschaft_aarberg),
          primary_state: "primary_group_selected",
          secondary_state: "opened",
          joint_participation: true
        )
      end

      it "to be present if it is a joint participation" do
        expect(subject.secondary_group).to be_nil

        is_expected.to_not be_valid

        subject.secondary_group = groups(:musikgesellschaft_alterswil)

        is_expected.to be_valid
      end

      it "to be unique in the event"
      it "to not be participating as primary group in the event"
    end

    context "music_style" do
      subject do
        described_class.new(
          event: events(:festival),
          group: groups(:musikgesellschaft_aarberg),
          primary_state: "music_style_selected"
        )
      end

      it "to be present" do
        expect(subject.music_style).to be_blank

        is_expected.to have_state(:music_style_selected).on(:primary)
        is_expected.to_not be_valid

        expect do
          subject.music_style = "concert_music"
        end.to change(subject, :valid?).to(true)
      end
    end

    context "music_type and music_level" do
      subject do
        described_class.new(
          event: events(:festival),
          group: groups(:musikgesellschaft_aarberg),
          primary_state: "music_type_and_level_selected"
        )
      end

      it "to be present" do
        expect(subject.music_type).to be_blank
        expect(subject.music_level).to be_blank

        is_expected.to_not be_valid

        expect do
          subject.music_type = "harmony"
          subject.music_level = "second"
        end.to change(subject, :valid?).to(true)
      end
    end
  end

  # if this constants is refactored away, please smile while deleting this spec
  it "has data some large constants" do
    expect(described_class::MUSIC_CLASSIFICATIONS).to be_an Array
  end
end
