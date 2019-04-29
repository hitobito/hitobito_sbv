#  Copyright (c) 2012-2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class HistoryRolesController < ApplicationController
  skip_load_and_authorize_resource

  def destroy
    role = Role.find(params[:id])
    person = role.person

    if authorize!(:destroy, role) && role.really_destroy!
      person.update_active_years
      flash[:notice] = I18n.t('crud.destroy.flash.success', model: role.to_s)

      redirect_to return_path(person)
    end
  end

  private

  def group
    @group ||= Group.find(params[:group_id])
  end

  def return_path(person)
    if group.people.include?(person)
      history_group_person_path(group, person.id)
    else
      group_path(group)
    end
  end

end
