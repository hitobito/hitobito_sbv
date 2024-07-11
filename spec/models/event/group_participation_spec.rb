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
        # :preferred_play_day_selected,
        :parade_music_selected
        # :terms_accepted
      ]

      expect(actual_states).to match_array(expected_states) # match items
      expect(actual_states).to eq(expected_states) # match items and order
    end

    it "has defined states on secondary" do
      actual_states = subject.aasm(:secondary).states.map(&:name)
      expected_states = [
        :not_present,
        :opened
        # :terms_accepted
      ]

      expect(actual_states).to match_array(expected_states) # match items
      expect(actual_states).to eq(expected_states) # match items and order
    end

    # more state-specs?
    # it { is_expected.to allow_event(:select_music_type) }
    # it { is_expected.to have_state(:completed) }
  end

  # context "has some state-machine helpers, which allow to" do
  #   subject do
  #     described_class.create(
  #       event: events(:festival),
  #       group: groups(:musikgesellschaft_aarberg),
  #       primary_state: "terms_accepted",
  #       terms_accepted: true
  #     )
  #   end

  #   it "check for completeness" do
  #     is_expected.to have_state(:terms_accepted).on(:primary)
  #     is_expected.to be_completed(subject.group)
  #   end

  #   it "progress a statemachine"
  #   it "get the current state of a statemachine"
  # end

  context "validates" do
    # context "preferred_play_days" do
    #   subject do
    #     described_class.create(
    #       event: events(:festival),
    #       group: groups(:musikgesellschaft_aarberg),
    #       primary_state: "music_type_and_level_selected",
    #       music_style: "concert_music",
    #       music_type: "harmony",
    #       music_level: "highest"
    #     )
    #   end

    #   it "to be different" do
    #     subject.preferred_play_day_1 = friday
    #     subject.preferred_play_day_2 = friday

    #     is_expected.to_not be_valid

    #     subject.preferred_play_day_1 = friday
    #     subject.preferred_play_day_2 = saturday

    #     is_expected.to be_valid
    #   end

    #   it "to be inferred if one is available but none is chosen" do
    #     subject.music_type = "brass_band"
    #     subject.music_level = "fourth"

    #     expect(subject.possible_day_numbers.size).to be 1
    #     expect(subject.possible_day_numbers).to include thursday

    #     subject.preferred_play_day_1 = nil
    #     subject.preferred_play_day_2 = nil

    #     is_expected.to be_valid

    #     expect(subject.preferred_play_day_1).to be thursday
    #     expect(subject.preferred_play_day_2).to be_nil
    #   end

    #   it "to be one if one is available" do
    #     subject.music_type = "brass_band"
    #     subject.music_level = "fourth"

    #     expect(subject.possible_day_numbers.size).to be 1
    #     expect(subject.possible_day_numbers).to include thursday

    #     subject.preferred_play_day_1 = thursday
    #     subject.preferred_play_day_2 = nil

    #     is_expected.to be_valid

    #     expect(subject.preferred_play_day_1).to be thursday
    #     expect(subject.preferred_play_day_2).to be_nil
    #   end

    #   it "infers second choice if two can be chosen and one is" do
    #     subject.music_type = "brass_band"
    #     subject.music_level = "highest"

    #     expect(subject.possible_day_numbers.size).to be 2
    #     expect(subject.possible_day_numbers).to include thursday
    #     expect(subject.possible_day_numbers).to include friday

    #     subject.preferred_play_day_1 = friday
    #     subject.preferred_play_day_2 = nil

    #     is_expected.to be_valid # validation with side-effects, sorry

    #     expect(subject.preferred_play_day_1).to be friday
    #     expect(subject.preferred_play_day_2).to be thursday
    #   end

    #   it "to be two choices if two or more can be chosen" do
    #     subject.preferred_play_day_1 = friday
    #     subject.preferred_play_day_2 = nil

    #     is_expected.to_not be_valid

    #     subject.preferred_play_day_1 = friday
    #     subject.preferred_play_day_2 = saturday

    #     is_expected.to be_valid
    #   end

    #   it "should be possible in schedule" do
    #     subject.preferred_play_day_1 = thursday
    #     subject.preferred_play_day_2 = saturday

    #     is_expected.to_not be_valid

    #     subject.preferred_play_day_1 = friday
    #     subject.preferred_play_day_2 = saturday

    #     is_expected.to be_valid
    #   end

    #   it "can be reset without breaking validation" do
    #     # cumbersome setup, sorry...
    #     subject.preferred_play_day_1 = friday
    #     subject.preferred_play_day_2 = saturday
    #     is_expected.to be_valid
    #     subject.progress_primary!
    #     expect(subject).to have_state(:preferred_play_day_selected).on(:primary)
    #     # cumbersome setup end

    #     subject.edit_date_preference

    #     expect(subject.preferred_play_day_1).to be_nil
    #     expect(subject.preferred_play_day_2).to be_nil
    #     is_expected.to be_valid
    #   end

    #   it "is not checked if the music has just been chosen" do
    #     sut = described_class.create(
    #       event: events(:festival),
    #       group: groups(:musikverband_hastdutoene),
    #       primary_state: "music_style_selected",
    #       music_style: "concert_music"
    #     )

    #     expect(sut).to be_valid

    #     sut.music_type = "harmony"
    #     sut.music_level = "highest"
    #     sut.progress_primary

    #     expect(sut).to have_state("music_type_and_level_selected")
    #       .on(:primary)
    #     expect(sut).to be_valid
    #   end
    # end

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

  # if these constants are refactored away, please smile while deleting this spec
  it "has data some large constants" do
    expect(described_class::MUSIC_CLASSIFICATIONS).to be_an Array
    expect(described_class::AVAILABLE_PLAY_DAYS).to be_a Hash
    expect(described_class::MUSIC_LEVEL_PLAY_DAYS).to be_a Hash
  end

  context "#may_prefer_two_days?" do
    subject do
      described_class.create(
        event: events(:festival),
        group: groups(:musikgesellschaft_aarberg),
        primary_state: "music_type_and_level_selected",
        music_style: "concert_music",
        music_type: "harmony",
        music_level: "first"
      )
    end

    it "uses possible_day_numbers as metric" do
      expect(subject.possible_day_numbers.size).to be 4
    end

    it "is true for four days" do
      expect(subject).to receive(:possible_day_numbers).and_return([1, 2, 3, 4])

      expect(subject).to be_may_prefer_two_days
    end

    it "is true for three days" do
      expect(subject).to receive(:possible_day_numbers).and_return([1, 2, 3])

      expect(subject).to be_may_prefer_two_days
    end

    it "is true for two days" do
      expect(subject).to receive(:possible_day_numbers).and_return([1, 2])

      expect(subject).to be_may_prefer_two_days
    end

    it "is false for one day" do
      expect(subject).to receive(:possible_day_numbers).and_return([1])

      expect(subject).to_not be_may_prefer_two_days
    end
  end

  context "deduces logical choices when there are few, it" do
    subject do
      described_class.create(
        event: events(:festival),
        group: groups(:musikgesellschaft_aarberg),
        primary_state: "music_type_and_level_selected",
        music_style: "concert_music",
        music_type: "brass_band",
        music_level: "highest"
      )
    end

    # it "assumes the second possible day when one is selected" do
    #   # possible values are thursday/4 and friday/5
    #   expect do
    #     subject.preferred_play_day_1 = thursday
    #     subject.progress_primary!
    #   end.to change { subject.preferred_play_day_2 }.from(nil).to(friday)
    #   # expect(subject.send :infer_play_day_preference).to change { :preferred_play_day_2 }.to friday
    # end

    # it "assumes the only day if only one is possible" do
    #   # the only possible value id thursday/4
    #   # simulate earlier step, because progress! needs to skip the day-selection
    #   subject.update(primary_state: "music_style_selected")
    #   expect do
    #     expect do
    #       subject.music_type = "brass_band"
    #       subject.music_level = "fourth"
    #       subject.progress_primary!
    #     end.to change { subject.preferred_play_day_1 }.from(nil).to(thursday)
    #   end.to change { subject.primary_state }
    #     .from("music_style_selected").to("preferred_play_day_selected")
    # end
  end

  private

  described_class::AVAILABLE_PLAY_DAYS.each do |day, value|
    define_method(day) do # def friday
      value               #   5
    end                   # end
  end
end
