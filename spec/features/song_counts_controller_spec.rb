require 'spec_helper'

describe SongCountsController, js: true do
  subject { page }

  let(:verein) { groups(:musikgesellschaft_alterswil) }

  before { sign_in(people(:suisa_admin)) }

  it 'adds song count to list' do
    visit group_song_counts_path(group_id: verein.id, year: 2018)

    within('.song-counts') do
      fill_in :q, with: 'Fortu'
      expect(page).to have_content 'Fortunate Son'
      click_link 'Fortunate Son'
      expect(page).to have_css('.list tr', count: 2)
    end

    expect(page).to have_content(/Werkmeldung.*wurde erfolgreich erstellt./)
  end

  it 'increments and decrements song count' do
    verein.song_counts.create!(song: songs(:papa), year: 2018, count: 3)
    visit group_song_counts_path(group_id: verein.id, year: 2018)

    first_column = '.song-counts .list tr:first-child td:first-child'
    expect(find(first_column)).to have_text '3'
    find("#{first_column} a[data-song-count=inc]").click
    expect(find(first_column)).to have_text '4'
    find("#{first_column} a[data-song-count=dec]").click
    expect(find(first_column)).to have_text '3'
  end

  it 'removes song count from list' do
    verein.song_counts.create!(song: songs(:papa), year: 2018, count: 3)
    visit group_song_counts_path(group_id: verein.id, year: 2018)
    within('.song-counts .list') do
      click_link 'Löschen'
    end
    expect(page).to have_css('.list tr', count: 0)
    expect(page).to have_content(/Werkmeldung.*wurde erfolgreich gelöscht./)
  end

  it 'adds new song and song count' do
    visit group_song_counts_path(group_id: verein.id, year: 2018)

    within('.song-counts') do
      fill_in :q, with: 'Fortu'
      expect(page).to have_content 'Werk erstellen'
      click_link 'Werk erstellen'
      fill_in 'Titel', with: 'Mamamia'
      fill_in 'Komponist', with: 'Abba'
      click_button 'Speichern'
    end
    expect(page).to have_css('.list tr', count: 2)
    expect(page).to have_content(/Werkmeldung.*wurde erfolgreich erstellt./)
  end

end
