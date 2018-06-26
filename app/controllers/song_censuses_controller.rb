#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SongCensusesController < ApplicationController
  include YearBasedPaging

  before_action :authorize

  helper_method :year, :group

  def index
    @group = Group.find(params[:group_id])
    @census = if params[:year]
                SongCensus.where(year: params[:year].to_i).last
              else
                SongCensus.current
              end
    @total = CensusCalculator.new(@census, @group).total
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
