#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SongCensusesController < ApplicationController
  include YearBasedPaging

  helper_method :year, :group

  def index
    authorize!(:index, SongCensus)
    @group = Group.find(params[:group_id])
    @census = if params[:year]
                SongCensus.where(year: params[:year].to_i).last
              else
                SongCensus.current
              end
    @total = CensusCalculator.new(@census, @group).total
  end

  # FIXME: simplify/clean up with dry_crud
  def create
    authorize!(:submit, SongCount)
    @group = Group.find(params[:group_id])
    if CensusSubmission.new(@group, SongCensus.current).submit
      flash[:notice] = flash_message(:success)
    else
      flash[:alert] = flash_message(:failure)
    end
    redirect_to group_song_counts_path(@group)
  end

  private

  def default_year
    @default_year ||= SongCensus.current.try(:year) || current_year
  end

  def current_year
    @current_year ||= Time.zone.today.year
  end

  def year_range
    @year_range ||= (year - 3)..(year + 1)
  end


  @@helper = Object.new
                   .extend(ActionView::Helpers::TranslationHelper)
                   .extend(ActionView::Helpers::OutputSafetyHelper)

  def flash_message(state)
    scope = "#{action_name}.flash.#{state}"
    keys = [:"#{controller_name}.#{scope}_html",
            :"#{controller_name}.#{scope}",
            :"crud.#{scope}_html",
            :"crud.#{scope}"]
    @@helper.t(keys.shift, model: SongCensus.name.humanize, default: keys)
  end
end
