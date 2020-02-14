#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Events::GroupParticipationsController < CrudController
  self.nesting = [Group, Event]
  self.permitted_attrs = [
    :music_style,
    :music_type,
    :music_level,
    :parade_music,
    :group_id,
    :joint_participation,
    :secondary_group_id,
    :secondary_group_is_primary,
    :preferred_play_day_1,
    :preferred_play_day_2,
    :terms_accepted,
    :secondary_group_terms_accepted
  ]

  decorates :event

  skip_authorize_resource
  skip_authorization_check

  before_action :participating_group, only: [:new, :edit]
  before_action :authorize_resource
  around_save :update_state_machine

  def edit_stage
    edit_event = :"edit_#{params[:edit_stage]}!"

    entry.send(edit_event) if entry.respond_to?(edit_event)

    redirect_to return_path
  end

  private_class_method

  def self.model_class
    Event::GroupParticipation
  end

  private

  def list_entries
    model_scope.includes(:event, :group, :secondary_group).all
  end

  def return_path
    edit_group_event_group_participation_path(
      @group, @event, entry,
      participating_group: participating_group_id
    )
  end

  def update_state_machine
    yield.tap do |result|
      entry.progress_for(participating_group || entry.group) if result
    end
  end

  def participating_group
    @participating_group ||= Group.find_by(id: participating_group_id)
  end

  def participating_group_id # rubocop:disable Metrics/AbcSize any refactoring inside the methods makes it harder to understand
    if params['participating_group'].present?
      params['participating_group']
    elsif params.fetch('event_group_participation', {}).fetch('participating_group', nil).present?
      params['event_group_participation']['participating_group']
    elsif params['group_id'].to_i != entry.event.group_ids.first
      @group.id # loaded by calling "entry"
    end
  end

  def authorize_resource
    if participating_group.present?
      authorize! :manage_festival_application, participating_group
    elsif entry.new_record?
      authorize! action_name.to_sym, @group
    else
      authorize! action_name.to_sym, entry
    end
  end

end
