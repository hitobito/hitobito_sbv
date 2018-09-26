# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Concert do

  context 'before validation' do
    it 'sets verband ids for verein nested under regionalverband ' do
      concert = Concert.create!(verein: groups(:musikgesellschaft_alterswil), year: 2018)

      expect(concert.regionalverband).to eq groups(:alt_thiesdorf_30)
      expect(concert.mitgliederverband).to eq groups(:societe_cantonale_des_musiques_fribourgeoises_freiburger_kantonal_musikverband_24)
    end

    it 'sets mitgliederverband for verein nested under mitgliederverband' do
      verein = Group::Verein.create!(name: 'group', parent: groups(:bernischer_kantonal_musikverband_8))
      concert = Concert.create!(verein: verein, year: 2018)

      expect(concert.regionalverband).to be_nil
      expect(concert.mitgliederverband).to eq groups(:bernischer_kantonal_musikverband_8)
    end

    it 'does not set verband ids for verein nested under root' do
      verein = Group::Verein.create!(name: 'group', parent: groups(:hauptgruppe_1))
      concert = Concert.create!(verein: verein, year: 2018)

      expect(concert.regionalverband).to be_nil
      expect(concert.mitgliederverband).to be_nil
    end

    it 'sets name if nothing is given' do
      concert1 = Concert.create!(verein: groups(:musikgesellschaft_alterswil), year: 2018)
      concert2 = Concert.create!(verein: groups(:musikgesellschaft_alterswil), year: 2018)
      concert3 = Concert.create!(verein: groups(:musikgesellschaft_alterswil), year: 2018)

      expect(concert1.name).to eq 'Aufführung #1'
      expect(concert2.name).to eq 'Aufführung #2'
      expect(concert3.name).to eq 'Aufführung #3'
    end

    it 'removes empty song counts' do
      song_counts = [SongCount.new(count: 0, song: songs(:papa), year: 2018),
                     SongCount.new(count: 0, song: songs(:son), year: 2018),
                     SongCount.new(count: 1, song: songs(:girl), year: 2018)]

      concert = Concert.create!(verein: groups(:musikgesellschaft_alterswil),
                                year: 2018,
                                song_counts: song_counts)

      expect(concert.song_counts.count).to be 1
      expect(concert.song_counts.first.song).to eq(songs(:girl))
    end
  end

  context 'validations' do
    it 'invalid name if already exists in verein and year' do
      Concert.create(name: 'same_name', verein: groups(:musikgesellschaft_alterswil), year: 2018)
      concert2 = Concert.create(name: 'same_name', verein: groups(:musikgesellschaft_alterswil), year: 2018)

      expect(concert2.errors[:name]).to include 'ist bereits vergeben'
    end

    it 'valid name if not same year' do
      Concert.create(name: 'same_name', verein: groups(:musikgesellschaft_alterswil), year: 2017)
      concert2 = Concert.create(name: 'same_name', verein: groups(:musikgesellschaft_alterswil), year: 2018)

      expect(concert2).to be_valid
    end
  end
end
