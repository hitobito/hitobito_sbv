#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Event::GroupParticipation do
  context 'is a state-machine which' do
    it { is_expected.to have_state(:initial) }
    it { is_expected.to allow_event(:select_music_style) }
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
          state: 'music_type_and_level_selected',
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

  private

  described_class::AVAILABLE_PLAY_DAYS.each do |day, value|
    define_method(day) do # def friday
      value               #   5
    end                   # end
  end
end
