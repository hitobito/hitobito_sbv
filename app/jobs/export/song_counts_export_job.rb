# frozen_string_literal: true

#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Export::SongCountsExportJob < Export::ExportBaseJob
  self.parameters = PARAMETERS + [:group_id, :year]

  def initialize(format, user_id, group_id, year, options)
    super(format, user_id, options)
    @exporter = Export::Tabular::SongCounts::List
    @group_id = group_id
    @year = year
  end

  def entries
    song_counts
      .joins(:concert, :song)
      .preload(:song)
      .group("concerts.verein_id", :song_id)
      # rubocop:todo Layout/LineLength
      .select("MAX(song_counts.id) AS id, song_id, MAX(song_counts.year) AS year, SUM(count) AS count, MAX(concert_id) AS concert_id")
      # rubocop:enable Layout/LineLength
      .in(@year)
      .order("MAX(songs.title)")
  end

  def song_counts
    Group.find(@group_id).song_counts
  end
end
