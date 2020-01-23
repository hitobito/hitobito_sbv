#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Event::GroupParticipation do
  context 'is a state-machine which' do
    subject do
      described_class.create(
        event: events(:festival),
        group: groups(:musikgesellschaft_aarberg)
      )
    end

    it { is_expected.to have_state(:opened).on(:primary) }
    it { is_expected.to allow_event(:progress).on(:primary) }
    it { is_expected.to allow_event(:progress).on(:secondary) }
    # more states?
    # it { is_expected.to allow_event(:select_music_type) }
    # it { is_expected.to have_state(:completed) }
  end

  context 'validates' do
    context 'preferred_play_days' do
      subject do
        described_class.create(
          event: events(:festival),
          group: groups(:musikgesellschaft_aarberg),
          primary_state: 'music_type_and_level_selected',
          music_style: 'concert_music',
          music_type: 'harmony',
          music_level: 'highest'
        )
      end

      it 'to be different' do
        subject.preferred_play_day_1 = friday
        subject.preferred_play_day_2 = friday

        is_expected.to_not be_valid

        subject.preferred_play_day_1 = friday
        subject.preferred_play_day_2 = saturday

        is_expected.to be_valid
      end

      it 'to be one or two choices' do
        subject.preferred_play_day_1 = friday
        subject.preferred_play_day_2 = nil

        is_expected.to be_valid

        subject.preferred_play_day_1 = friday
        subject.preferred_play_day_2 = saturday

        is_expected.to be_valid
      end

      it 'should be possible in schedule' do
        subject.preferred_play_day_1 = thursday

        is_expected.to_not be_valid

        subject.preferred_play_day_1 = friday

        is_expected.to be_valid
      end
    end
  end

  # if these constants are refactored away, please smile while deleting this spec
  it 'has data some large constants' do
    expect(described_class::MUSIC_CLASSIFICATIONS).to be_an Array
    expect(described_class::AVAILABLE_PLAY_DAYS).to be_a Hash
    expect(described_class::MUSIC_LEVEL_PLAY_DAYS).to be_a Hash
  end

  context '#may_prefer_two_days?' do
    subject do
      described_class.create(
        event: events(:festival),
        group: groups(:musikgesellschaft_aarberg),
        primary_state: 'music_type_and_level_selected',
        music_style: 'concert_music',
        music_type: 'harmony',
        music_level: 'first'
      )
    end

    it 'uses possible_day_numbers as metric' do
      expect(subject.possible_day_numbers.size).to be 4
    end

    it 'is true for four days' do
      expect(subject).to receive(:possible_day_numbers).and_return([1, 2, 3, 4])

      expect(subject).to be_may_prefer_two_days
    end

    it 'is true for three days' do
      expect(subject).to receive(:possible_day_numbers).and_return([1, 2, 3])

      expect(subject).to be_may_prefer_two_days
    end

    it 'is false for two days' do
      expect(subject).to receive(:possible_day_numbers).and_return([1, 2])

      expect(subject).to_not be_may_prefer_two_days
    end

    it 'is false for one day' do
      expect(subject).to receive(:possible_day_numbers).and_return([1])

      expect(subject).to_not be_may_prefer_two_days
    end
  end

  context 'deduces logical choices when there are few, it' do
    subject do
      described_class.create(
        event: events(:festival),
        group: groups(:musikgesellschaft_aarberg),
        primary_state: 'music_type_and_level_selected',
        music_style: 'concert_music',
        music_type: 'brass_band',
        music_level: 'highest'
      )
    end

    it 'assumes the second possible day when one is selected' do
      # possible values are thursday/4 and friday/5
      expect do
        subject.preferred_play_day_1 = thursday
        subject.progress_primary!
      end.to change { subject.preferred_play_day_2 }.from(nil).to(friday)
        # expect(subject.send :infer_play_day_preference).to change { :preferred_play_day_2 }.to friday
    end

    it 'assumes the only day if only one is possible' do
      # the only possible value id thursday/4
      # simulate earlier step, because progress! needs to skip the day-selection
      subject.update_attributes(primary_state: 'music_style_selected')

      expect do
        expect do
          subject.music_type = 'brass_band'
          subject.music_level = 'fourth'
          subject.progress_primary!
        end.to change { subject.preferred_play_day_1 }.from(nil).to(thursday)
      end.to change { subject.primary_state }
         .from('music_style_selected').to('preferred_play_day_selected')
    end
  end

  private

  described_class::AVAILABLE_PLAY_DAYS.each do |day, value|
    define_method(day) do # def friday
      value               #   5
    end                   # end
  end
end
