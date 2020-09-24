# frozen_string_literal: true

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class ConcertsController < SimpleCrudController
  include YearBasedPaging

  self.nesting = Group
  self.permitted_attrs = [:name, :performed_at, :year, :verein_id, :song_census_id,
                          :reason,
                          song_counts_attributes: [
                            :id,
                            :count,
                            :song_id,
                            :year,
                            :_destroy
                          ]]

  helper_method :census

  after_create :remove_existing_unplayed_concerts

  def new
    entry.song_counts = parent.last_played_song_ids.map do |id|
      SongCount.new(song_id: id, count: 0)
    end
  end

  def submit
    submitted = with_callbacks(:create, :save) do
      CensusSubmission.new(parent, census).submit
    end
    respond_with(parent, success: submitted, location: group_concerts_path(parent))
  end

  private

  def remove_existing_unplayed_concerts
    (entry.verein.concerts.not_played - [entry]).each(&:really_destroy)
  end

  def assign_attributes
    super
    entry.name ||= entry.reason_label
    nil
  end

  def find_entry
    model_scope.includes(song_counts: :song).find(params[:id])
  end

  def list_entries
    list = super.includes(song_counts: :song).includes(:song_census).in(year).without_deleted

    if list.present? && list.any?(&:played?)
      list.where(reason: nil)
    else
      list
    end
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
    authorize!(:index_concerts, parent)
  end

end
