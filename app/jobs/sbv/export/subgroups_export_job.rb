# frozen_string_literal: true

#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Export::SubgroupsExportJob
  def initialize(user_id, group_id, options)
    super
    @exporter = Export::Tabular::Groups::AddressList
  end

  private

  def entries
    primary_entries = super.where(type: types.map(&:sti_name))

    potential_parents = primary_entries.where(type: (types - [Group::Verein]).map(&:sti_name))
    secondary_entries = Group::Verein.where(secondary_parent_id: potential_parents.pluck(:id))
      .without_deleted.order(:lft).includes(:contact) # like in core

    deduplicated_secondary_entries = secondary_entries - primary_entries

    primary_entries + deduplicated_secondary_entries
  end

  def types
    [
      Group::Mitgliederverband,
      Group::Regionalverband,
      Group::Verein
    ]
  end
end
