class SongCensusEvaluation::RootController < ApplicationController

  include YearBasedPaging

  before_action :authorize

  helper_method :year

  def show
    @group = Group.find(params[:group_id])
  end

  private

  def authorize
    authorize!(:index, SongCensus)
  end

  def year
    2018
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


end
