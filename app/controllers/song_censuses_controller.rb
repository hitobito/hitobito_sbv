#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SongCensusesController < ApplicationController
  include YearBasedPaging

  helper_method :year, :group

  def index
    authorize!(:index, SongCensus)
    @census = if params[:year]
                SongCensus.where(year: params[:year].to_i).last
              else
                SongCensus.current
              end
    @total = CensusCalculator.new(@census, group).total
  end

  def remind # rubocop:disable Metrics/AbcSize
    authorize!(:index, SongCensus)

    census = SongCensus.find(params[:song_census_id])
    vereins_total = CensusCalculator.new(census, group).vereins_total

    count = group.descendants.where(type: Group::Verein).collect do |verein|
      next if vereins_total[verein.id]
      verein.suisa_admins.each do |suisa_admin|
        SongCensusMailer.reminder(suisa_admin, verein).deliver_now
      end
    end.compact.count

    redirect_to :back, notice: t('.success', verein_count: count)
  end

  # FIXME: simplify/clean up with dry_crud
  def create
    authorize!(:submit, SongCount)
    if CensusSubmission.new(group, SongCensus.current).submit
      flash[:notice] = flash_message(:success)
    else
      flash[:alert] = flash_message(:failure)
    end
    redirect_to group_song_counts_path(group)
  end

  private

  def group
    @group ||= Group.find(params[:group_id])
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
