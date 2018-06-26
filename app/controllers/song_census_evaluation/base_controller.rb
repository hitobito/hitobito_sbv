module SongCensusEvaluation
  class BaseController < ApplicationController
    include YearBasedPaging

    before_action :authorize

    helper_method :year, :group

    def show
      @group = Group.find(params[:group_id])
      @census = if params[:year]
                  SongCensus.where(year: params[:year].to_i).last
                else
                  SongCensus.current
                end
    end

    private

    def authorize
      authorize!(:index, SongCensus)
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
end
