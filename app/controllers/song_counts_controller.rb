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
  self.sort_mappings = {title: {
                          joins: [:song],
                          order: ["songs.title"]
                        },
                         composed_by: {
                           joins: [:song],
                           order: ["songs.composed_by"]
                         },
                         arranged_by: {
                           joins: [:song],
                           order: ["songs.arranged_by"]
                         }}

  respond_to :js
  helper_method :census

  def index
    respond_to do |format|
      format.html { super }
      format.csv { render_tabular_in_background(:csv) }
      format.xlsx { render_tabular_in_background(:xlsx) }
    end
  end

  private

  def redirection_target
  end

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
    verein_name = @group.name if verein?

    [SongCount.model_name.human,
      verein_name,
      year].compact.join("-")
  end

  def list_entries
    entries = Group.find(params[:group_id]).song_counts
      .joins(:concert, :song)
      .preload(:song)
      .group(:song_id)
      .select("MAX(song_counts.id), song_id, MAX(song_counts.year), SUM(count) AS count, MAX(concert_id)")
      .in(year)
      .order("MAX(songs.title)")

    sort_by_sort_expression(entries)
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
