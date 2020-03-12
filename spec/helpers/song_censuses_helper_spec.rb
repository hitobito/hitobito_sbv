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

  describe '#census_finish_button' do
    context 'for a current, finished census, it' do
      let(:census) { song_censuses(:two_o_18) }
      let(:group) { groups(:hauptgruppe_1) }

      let(:today) { Date.parse('2018-12-01') }

      it 'deals with a current census' do
        expect(census).to be_current
      end

      it 'deals with a finished census' do
        expect(census).to be_finished
      end

      it 'allows to finish the census' do
        button_html = census_finish_button(census, group.id)
        message = I18n.t('song_censuses.finish.start_new_census')

        expect(button_html).to match(/div.*btn-group.*/)
        expect(button_html).to match(/a.*data-confirm="#{message}"/)
        expect(button_html).to match(new_group_song_census_path(group.id))
        expect(button_html).to match(/Meldeliste abschliessen/)
      end
    end
  end

  describe '#census_submit_button' do
    let(:today) { Date.parse('2018-12-01') } # determines the current census, but useless to change per context
    let(:group) { groups(:musikverband_hastdutoene) }

    let(:disabled_class_regex) { /div class="tooltip-wrapper".*a class="[^"]*disabled[^"]*"/ }
    let(:button_class_regex) { /class="[^"]*btn[^"]*"/ }
    let(:button_html) { census_submit_button(concerts, group) }

    context 'if the census is not yet submitted, it' do
      let(:concerts) { group.concerts }

      it 'has concerts that are not linked to a census' do
        expect(concerts.any? { |concert| concert.song_census.nil? }).to be_truthy
      end

      it 'renders a button to submit' do
        label   = 'Meldeliste einreichen'
        tooltip = 'Die Meldeliste kann eingereicht werden.'

        expect(button_html).to be_a String

        expect(button_html).to include(label)
        expect(button_html).to include(%(title="#{tooltip}"))

        expect(button_html).to match(/div.*btn-group.*/)
        expect(button_html).to match(button_class_regex)
        expect(button_html).to match(/data-method="post"/)
        expect(button_html).to include(submit_group_concerts_path(group.id))

        expect(button_html).to_not match(disabled_class_regex)
      end
    end

    context 'if the census has already been submitted, it' do
      let(:concerts) do
        group.concerts.map do |concert|
          if concert.song_census.nil?
            concert.update_attribute(:song_census, SongCensus.current)
          end
          concert
        end
      end

      it 'has concerts that are linked to the current census' do
        expect(concerts.any? { |concert| concert.song_census.current? }).to be_truthy
      end

      it 'has no concerts that are not linked to a census' do
        expect(concerts.any? { |concert| concert.song_census.nil? }).to be_falsey
      end

      it 'renders an inactive button' do
        label   = 'Meldeliste eingereicht'
        tooltip = 'Die Meldeliste wurde bereits erfolgreich eingereicht.'

        expect(button_html).to be_a String

        expect(button_html).to include(label)
        expect(button_html).to include(%(title="#{tooltip}"))

        expect(button_html).to match(/div.*btn-group.*/)
        expect(button_html).to match(button_class_regex)
        expect(button_html).to_not match(/data-method="post"/)
        expect(button_html).to_not include(submit_group_concerts_path(group.id))

        expect(button_html).to match(disabled_class_regex)
      end
    end

    context 'if there are no concerts for the census, it' do
      let(:concerts) { Concert.none }

      it 'has no concerts that are linked to the current census' do
        expect(concerts.any? { |concert| concert.song_census.current? }).to be_falsey
      end

      it 'has no concerts that are not linked to a census' do
        expect(concerts.any? { |concert| concert.song_census.nil? }).to be_falsey
      end

      it 'has no concerts' do
        expect(concerts).to be_none
      end

      it 'renders an inactive button' do
        label   = 'Meldeliste einreichen'
        tooltip = 'Keine Meldelisten zum einreichen.'

        expect(button_html).to be_a String

        expect(button_html).to include(label)
        expect(button_html).to include(%(title="#{tooltip}"))

        expect(button_html).to match(/div.*btn-group.*/)
        expect(button_html).to match(button_class_regex)
        expect(button_html).to_not match(/data-method="post"/)
        expect(button_html).to_not include(submit_group_concerts_path(group.id))

        expect(button_html).to match(disabled_class_regex)
      end
    end
  end
end
