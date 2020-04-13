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

  self.sort_mappings = {
    group_id: 'groups.name',
  }

  decorates :event

  skip_authorize_resource
  skip_authorization_check

  before_action :participating_group, only: [:new, :edit]
  before_action :authorize_resource
  around_save :update_state_machine

  def edit_stage
    edit_event = :"edit_#{params[:edit_stage]}"

    if entry.respond_to?(edit_event)
      entry.send(edit_event)
      entry.save!(validate: false)
    end

    redirect_to return_path
  end

  private_class_method

  def self.model_class
    Event::GroupParticipation
  end

  private

  def list_entries_without_sort
    model_scope.includes(:group, :secondary_group)
  end

  def return_path
    edit_group_event_group_participation_path(
      @group, @event, entry,
      participating_group: participating_group_id
    )
  end

  def update_state_machine
    maybe_join_participations

    entry.progress_for(participating_group || entry.group) if entry.valid?
    yield.tap do |result|
      entry.restore_attributes(%w(primary_state secondary_state)) unless result
    end
  end

  def participating_group
    @participating_group ||= Group.find_by(id: participating_group_id).try(:layer_group)
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

  def maybe_join_participations
    return unless entry.primary_joint_participation_selected?
    return unless entry.secondary_group_is_primary == '1'

    join_participations!(primary_entry: model_class.find_by(group_id: entry.secondary_group_id),
                         secondary_entry: entry)
  end

  def join_participations!(primary_entry:, secondary_entry:)
    return if primary_entry.blank?

    primary_entry.join_secondary
    primary_entry.joint_participation = true
    primary_entry.secondary_group = secondary_entry.group

    if primary_entry.primary_opened?
      primary_entry.state = model_class::STATE_PRIMARY_JOINT_PARTICIPATION_SELECTED
    end

    secondary_entry.destroy!
    model_ivar_set(primary_entry)
  end
end
