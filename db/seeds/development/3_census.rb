#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

# past years
[Date.today.year - 2, Date.today.year - 1].each do |year|
  SongCensus.seed_once(:year) do |census|
    census.year = year
    census.start_at = Date.new(year - 1, 12, 1)
    census.finish_at = Date.new(year, 11).end_of_month
  end
end

# current census
[Date.today.year].each do |year|
  SongCensus.seed_once(:year) do |census|
    census.year = year
    census.start_at = Date.new(year - 1, 12, 1)
    census.finish_at = Date.new(year, 11).end_of_month
  end
end

current_census = SongCensus.current
vereine        = Group::Verein.all.shuffle.take(10)
songs          = Song.all.shuffle.take(10)

SongCensus.all.each do |census|
  vereine.each do |verein|
    songs.each do |song|
      SongCount.seed_once(:song_census_id, :verein_id, :song_id) do |count|
        count.song_census_id = census.id
        count.verein_id = verein.id
        count.regionalverband_id = verein.parent.id if verein.parent.is_a?(Group::Regionalverband)
        count.mitgliederverband_id = verein.parent.parent.id if verein.parent.try(:parent).is_a?(Group::Mitgliederverband)
        count.song_id = song.id
        count.year = census.year
        count.editable = (census == current_census)
      end
    end
  end
end
