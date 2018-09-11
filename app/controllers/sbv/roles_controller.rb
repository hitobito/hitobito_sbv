module Sbv
  module RolesController
    extend ActiveSupport::Concern

    def create_history_member
      person_id = params[:role][:person_id]
      assign_history_attributes

      unless entry.save
        set_failure_notice
      end

      redirect_to history_group_person_path(id: person_id)
    end

    private

    def assign_history_attributes
      assign_attributes
      @group = @group.children.find_by(type: 'Group::VereinMitglieder')
      entry.group_id = @group.id
      entry.type = 'Group::VereinMitglieder::Mitglied'
      entry.created_at = params[:role][:start_date].to_date rescue nil
      entry.deleted_at = params[:role][:end_date].to_date rescue nil
    end

  end
end
