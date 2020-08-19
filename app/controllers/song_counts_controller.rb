# frozen_string_literal: true
#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SongCountsController < SimpleCrudController
  include YearBasedPaging
  include AsyncDownload

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
      format.csv  { render_tabular_in_background(:csv) }
      format.xlsx { render_tabular_in_background(:xlsx) }
    end
  end

  private

  def redirection_target; end

  def verein?
    @group.is_a?(Group::Verein)
  end

  def render_tabular_in_background(format)
    target = verein? ? group_concerts_path(@group) : group_song_censuses_path(@group)
    with_async_download_cookie(format, export_filename(format),
                               redirection_target: target) do |filename|
      Export::SongCountsExportJob.new(format,
                                      current_person.id,
                                      parent.id,
                                      year,
                                      filename: filename).enqueue!
    end
  end

  def export_filename(_format)
    str = SongCount.model_name.human
    if verein?
      str << "-#{@group.name}"
    end
    str + "-#{year}"
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
