# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe ConcertsController, js: true do

  subject { page }
  let(:verein)  { groups(:musikgesellschaft_alterswil) }
  let(:concert) { concerts(:third_concert) }

  before do
    SongCount.delete_all
    sign_in(people(:suisa_admin))
  end

  it 'adds song count to list' do
    visit new_group_concert_path(group_id: verein.id, year: 2018)

    within('#song_counts_typeahead') do
      fill_in :q, with: 'Fortu'
      expect(page).to have_content 'Fortunate Son'
      find('ul[role="listbox"] li[role="option"]', text: "Fortunate Son").click
    end

    expect(page).to have_css('#song_counts_fields .fields', count: 1)
  end

  it 'increments and decrements song count' do
    concert.song_counts.create!(song: songs(:papa), year: 2018, count: 3)
    visit edit_group_concert_path(group_id: verein.id, id: concert.id)

    first_column = '#song_counts_fields .fields:first-child'
    expect(find("#{first_column} .count input").value).to eq('3')
    find("#{first_column} .inc_song_count").click
    expect(find("#{first_column} .count input").value).to eq('4')
    find("#{first_column} .dec_song_count").click
    expect(find("#{first_column} .count input").value).to eq('3')
  end

  it 'removes song count from list' do
    concert.song_counts.create!(song: songs(:papa), year: 2018, count: 3)
    visit edit_group_concert_path(group_id: verein.id, id: concert.id)
    within('#song_counts_fields') do
      # click the former "Entfernen" link which now only has an icon without text
      find('a.remove_nested_fields').click
    end
    expect(page).to have_css('#song_counts_fields .fields', count: 0)
  end

  it 'adds new song and song count' do
    visit new_group_concert_path(group_id: verein.id, year: 2018)

    within('#song_counts_typeahead') do
      fill_in :q, with: 'unknown'
      expect(page).to have_content 'Werk erstellen'
      find('ul[role="listbox"] li[role="option"]', text: "Werk erstellen").click

      fill_in 'Titel', with: 'Mamamia'
      fill_in 'Komponist', with: 'Abba'
      click_button 'Werk erstellen'
    end

    expect(page).to have_css('#song_counts_fields .fields', count: 1)
    expect(page).to have_content 'Mamamia'
  end

  it 'hides new song form' do
    visit new_group_concert_path(group_id: verein.id, year: 2018)

    within('#song_counts_typeahead') do
      fill_in :q, with: 'unknown'
      find('ul[role="listbox"] li[role="option"]', text: "Werk erstellen").click
      expect(page).to have_button 'Werk erstellen'
      click_link 'Abbrechen'
      expect(page).not_to have_button 'Werk erstellen'
    end
  end

end
