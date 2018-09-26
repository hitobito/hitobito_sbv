require 'spec_helper'

describe SongCount do

  context 'validations' do
    it 'cannot set count over 30' do
      song_count = SongCount.create(count: 31)
      expect(song_count).not_to be_valid
      expect(song_count.errors.full_messages).to include('Anzahl muss kleiner oder gleich 30 sein')
    end

    it 'cannot set count less then zero' do
      song_count = SongCount.create(count: -1)
      expect(song_count).not_to be_valid
      expect(song_count.errors.full_messages).to include('Anzahl muss grösser oder gleich 1 sein')
    end
  end
end
