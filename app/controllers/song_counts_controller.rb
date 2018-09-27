#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SongCountsController < SimpleCrudController
  include YearBasedPaging

  self.nesting = Group
  self.permitted_attrs = [:song_id, :year, :count]
  self.sort_mappings = { title: 'songs.title',
                         composed_by: 'songs.composed_by',
                         arranged_by: 'songs.arranged_by' }

  respond_to :js
  helper_method :census

  def index
    respond_to do |format|
      format.html { super }
      format.csv  { render_song_counts_tabular(:csv) }
      format.xlsx { render_song_counts_tabular(:xlsx) }
    end
  end

  private

  def render_song_counts_tabular(format)
    list = Export::Tabular::SongCounts::List.send(format, list_entries)
    send_data list, type: format, filename: export_filename(format)
  end

  def export_filename(format)
    str = SongCount.model_name.human
    if @group.is_a?(Group::Verein)
      str << "-#{@group.name.tr(' ', '_').underscore}"
    end
    str + "-#{year}.#{format}"
  end

  def list_entries
    super.joins(:concert, :song)
         .preload(:song)
         .group(:song_id)
         .select('song_counts.id, song_id, song_counts.year, SUM(count) AS count, concert_id')
         .in(year)
         .merge(Song.list)
  end

  def census
    SongCensus.current
  end

  def default_year
    @default_year ||= census.try(:year) || current_year
  end

  def current_year
    @current_year ||= Time.zone.today.year
  end

  def year_range
    @year_range ||= (year - 3)..(year + 1)
  end

  def authorize_class
    authorize!(:index_song_counts, parent)
  end

end
