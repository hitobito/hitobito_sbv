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
    @year     = year
  end

  def entries
    song_counts
      .joins(:concert, :song)
      .preload(:song)
      .group('`concerts`.`verein_id`', :song_id)
      .select('song_counts.id, song_id, song_counts.year, SUM(count) AS count, concert_id')
      .in(@year)
      .merge(Song.list)
  end

  def song_counts
    Group.find(@group_id).song_counts
  end
end
