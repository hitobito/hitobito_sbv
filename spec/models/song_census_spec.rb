# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe SongCensus do

  describe '.last' do
    subject { SongCensus.last }

    it { is_expected.to eq(song_censuses(:two_o_18)) }
  end

  describe '.current' do
    subject { SongCensus.current }

    it { is_expected.to eq(song_censuses(:two_o_17)) }
  end
end
