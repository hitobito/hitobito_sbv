#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class HistoryRolesController < ApplicationController
  skip_load_and_authorize_resource

  def create # rubocop:disable Metrics/AbcSize,MethodLength
    role = build_role(find_or_create_group)
    person = role.person

    authorize!(:create_history_member, role)

    if (role_group_id || role_group_name) && role.save
      person.update_active_years
      flash[:notice] = I18n.t('crud.create.flash.success', model: role.to_s)
      redirect_to return_path(role.person)
    else
      flash.now[:alert] = [role, role.group].flat_map { |m| m.errors.full_messages }.compact
      render 'shared/update_flash'
    end
  end

  def destroy
    role = Role.with_deleted.find(params[:id])
    person = role.person
    authorize!(:destroy, role)

    if role.really_destroy!
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

  def build_role(group)
    Group::VereinMitglieder::Mitglied.new(
      group: group,
      person_id: params[:role][:person_id],
      created_at: params[:role][:start_date].presence || Time.zone.now.to_date,
      deleted_at: params[:role][:end_date]
    )
  end

  def find_or_create_group(scope = Group::Verein::VereinMitglieder)
    scope.find_by(id: role_group_id) ||
      scope.deleted.find_by(name: params[:role][:group][:name]) ||
      scope.create(parent: Group::Verein.hidden,
                   name: role_group_name,
                   deleted_at: Time.zone.now)
  end

  def role_group_id
    params[:role][:group_id].presence
  end

  def role_group_name
    params[:role][:group][:name].presence
  end

end
