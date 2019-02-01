#  Copyright (c) 2012-2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module RolesController
    extend ActiveSupport::Concern

    def create_history_member
      person_id = params[:role][:person_id]
      assign_history_attributes

      if entry.save
        update_active_years_on_person(::Person.find(person_id))
      else
        set_failure_notice
      end

      redirect_to history_group_person_path(id: person_id)
    end

    private

    # rubocop:disable Style/RescueModifier
    def assign_history_attributes
      assign_attributes
      @group = @group.children.find_by(type: 'Group::VereinMitglieder')
      entry.group_id = @group.id
      entry.type = 'Group::VereinMitglieder::Mitglied'
      entry.created_at = params[:role][:start_date].to_date rescue nil
      entry.deleted_at = params[:role][:end_date].to_date rescue nil
    end
    # rubocop:enable Style/RescueModifier

    def update_active_years_on_person(person)
      return unless person

      person.cache_active_years
      person.save(validate: false)
    end

  end
end
