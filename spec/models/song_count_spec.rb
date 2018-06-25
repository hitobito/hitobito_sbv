require 'spec_helper'

describe SongCount do

  it 'sets verband ids for verein nested under regionalverband ' do
    song_count = SongCount.create!(song: songs(:papa),
                                   verein: groups(:musikgesellschaft_alterswil),
                                   year: 2018)

    expect(song_count.regionalverband).to eq groups(:alt_thiesdorf_30)
    expect(song_count.mitgliederverband).to eq groups(:societe_cantonale_des_musiques_fribourgeoises_freiburger_kantonal_musikverband_24)
  end

  it 'sets mitgliederverband for verein nested under mitgliederverband' do
    verein = Group::Verein.create!(name: 'group', parent: groups(:bernischer_kantonal_musikverband_8))
    song_count = SongCount.create!(song: songs(:papa),
                                   verein: verein,
                                   year: 2018)

    expect(song_count.regionalverband).to be_nil
    expect(song_count.mitgliederverband).to eq groups(:bernischer_kantonal_musikverband_8)
  end

  it 'does not set verband ids for verein nested under root' do
    verein = Group::Verein.create!(name: 'group', parent: groups(:hauptgruppe_1))
    song_count = SongCount.create!(song: songs(:papa),
                                   verein: verein,
                                   year: 2018)

    expect(song_count.regionalverband).to be_nil
    expect(song_count.mitgliederverband).to be_nil
  end
end
