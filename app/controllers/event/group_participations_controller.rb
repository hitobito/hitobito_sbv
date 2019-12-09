#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Event::GroupParticipationsController < ApplicationController
  skip_authorization_check

  decorates :event, :group

  def new
    @group = Group.find(params[:group_id])
    @event = Event.find(params[:id])
  end

  def create; end
end
