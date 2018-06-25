class SongCountsController < SimpleCrudController
  include YearBasedPaging

  self.nesting = Group
  self.permitted_attrs = [:song_id, :year, :count]
  self.sort_mappings = { title: 'songs.title',
                         composed_by: 'songs.composed_by',
                         arranged_by: 'songs.arranged_by' }

  respond_to :js

  def create
    assign_attributes
    respond_with_flash { save_entry }
  end

  def destroy
    respond_with_flash { entry.destroy }
  end

  private

  def respond_with_flash
    if yield
      flash.now[:notice] = flash_message(:success)
    else
      flash.now[:alert] = failure_notice
    end

    respond_with(entry)
  end

  def list_entries
    super.includes(:song).references(:song).in(year)
  end

  def failure_notice
    error_messages.presence || flash_message(:failure)
  end

  def default_year
    @default_year ||= SongCensus.current.try(:year) || current_year
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
