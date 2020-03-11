# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe SongCensusesHelper do
  include ActiveSupport::Testing::TimeHelpers
  before { travel_to today }
  after  { travel_back }

  include LayoutHelper # action_button
  include UtilityHelper # add_css_class

  let(:group) { groups(:hauptgruppe_1) }
  let(:button_html) { census_finish_button(census, group.id) }

  context 'for a current, finished census, it' do
    let(:census) { song_censuses(:two_o_18) }
    let(:today) { Date.parse('2018-12-01') }

    it 'deals with a current census' do
      expect(census).to be_current
    end

    it 'deals with a finished census' do
      expect(census).to be_finished
    end

    it 'allows to finish the census' do
      message = I18n.t('song_censuses.finish.start_new_census')

      expect(button_html).to match(/div.*btn-group.*/)
      expect(button_html).to match(/a.*data-confirm="#{message}"/)
      expect(button_html).to match(new_group_song_census_path(group.id))
      expect(button_html).to match(/Meldeliste abschliessen/)
    end
  end
end
