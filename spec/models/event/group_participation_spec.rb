#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
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
end
