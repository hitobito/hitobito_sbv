#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Events::GroupParticipationsController < ApplicationController
  skip_authorization_check # FIXME: implement this

  decorates :event, :group

  before_action :event, :group, only: [:index, :new, :edit]

  def index
    @participations = Event::GroupParticipation.where(event: event)
  end

  def new
    @participation = Event::GroupParticipation.new(group: group, event: event)
  end

  def create
    @participation = Event::GroupParticipation.create!(group: group, event: event)

    redirect_to group_event_path(group, event), notice: t('.success')
  end

  def edit
    @participation = Event::GroupParticipation.find(params[:id])
  end

  def update
    @participation = Event::GroupParticipation.find(params[:id])

    @participation.assign_attributes(participation_params)

    @participation.select_music_style! if @participation.save

    redirect_to group_event_path(group, event), notice: t('.success')
  end

  private

  def group
    @group ||= Group.find(params[:group_id])
  end

  def event
    @event ||= Event.find(params[:event_id])
  end

  def participation_params
    params.require(:event_group_participation).permit(:music_style)
  end
end
