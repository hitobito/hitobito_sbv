# frozen_string_literal: true

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SongAbility < AbilityDsl::Base

  on(Song) do
    permission(:song_census).may(:create, :index, :show).all
    permission(:song_census).may(:manage).in_dachverband
  end

  on(SongCount) do
    permission(:song_census).may(:manage).in_verein_or_mitgliederverband
    permission(:layer_and_below_read).may(:read).in_verein
  end

  on(Concert) do
    permission(:song_census).may(:manage).in_dachverband
    permission(:song_census).may(:manage).in_verein_or_mitgliederverband
    permission(:song_census).may(:submit).in_verein_or_mitgliederverband
    permission(:song_census).may(:create).in_verein_or_mitgliederverband
    permission(:layer_and_below_read).may(:read).in_verein
  end

  on(Group) do
    permission(:song_census).may(:index_concerts).in_layer
    permission(:song_census).may(:index_song_counts).in_layer
    permission(:song_census).may(:manage_song_census).in_layer_or_below_if_mitgliederverband
  end

  def in_verein_or_mitgliederverband
    if role_type?(Group::Mitgliederverband::SuisaAdmin)
      in_verein || in_mitgliederverband
    else
      in_verein
    end
  end

  def in_layer_or_below_if_mitgliederverband
    if role_type?(Group::Mitgliederverband::SuisaAdmin)
      in_layer_or_below
    else
      in_layer
    end
  end

  def in_verein
    permission_in_group?(subject.verein_id)
  end

  def in_mitgliederverband
    if subject.mitgliederverband_id.nil? && subject.respond_to?(:infer_verband_ids)
      subject.infer_verband_ids
    end
    permission_in_group?(subject.mitgliederverband_id)
  end

  def in_layer
    subject.self_and_ancestors.any? do |group|
      user.groups_with_permission(:song_census).include?(group)
    end
  end

  def in_layer_or_below
    in_layer ||
      permission_in_layers?(subject.layer_hierarchy.collect(&:id)) ||
      permission_in_groups?(subject.local_hierarchy.collect(&:id))
  end

  def in_dachverband
    user.groups_with_permission(:song_census).include?(Group::Root.all)
  end

end
