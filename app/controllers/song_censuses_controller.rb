#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SongCensusesController < CrudController

  include YearBasedPaging

  self.permitted_attrs = [:song_id, :year, :count]

  helper_method :group

  skip_authorize_resource
  before_action :authorize_class

  def index
    @census = SongCensus.where(year: year).last
    @total = CensusCalculator.new(@census, group).total
  end

  def create
    SongCensus.current.touch(:finish_at) # rubocop:disable Rails/SkipsModelValidations if this makes a census invalid, it reflects an invalid reality...
    super(location: group_song_censuses_path(group))
  end

  def remind
    census = SongCensus.find(params[:song_census_id])
    vereins_total = CensusCalculator.new(census, group).vereins_total
    count = deliver_reminders(vereins_total)

    redirect_to :back, notice: t('.success', verein_count: count)
  end

  private

  def authorize_class
    authorize!(:manage_song_census, group)
  end

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


  # extracted methods

  def deliver_reminders(vereins_total)
    group.descendants.where(type: Group::Verein).collect do |verein|
      next if vereins_total[verein.id]
      verein.suisa_admins.each do |suisa_admin|
        SongCensusMailer.reminder(suisa_admin, verein).deliver_now
      end
    end.compact.count
  end

end
