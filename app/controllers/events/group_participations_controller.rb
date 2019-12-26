#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Events::GroupParticipationsController < CrudController
  self.nesting = [Group, Event]
  self.permitted_attrs = [:music_style, :music_level, :group_id]

  decorates :event

  skip_authorize_resource
  skip_authorization_check

  def self.model_class
    Event::GroupParticipation
  end

  before_action :participating_group, only: [:new]

  # def update
  #   @participation = Event::GroupParticipation.find(params[:id])
  #   @participation.assign_attributes(participation_params)
  #   @participation.progress_in_application! if @participation.save
  #   redirect_to group_event_path(group, event), notice: t('.success')
  # end


  private

  def participating_group
    @participating_group ||= Group.find_by(id: params['participating_group'])
  end
end
