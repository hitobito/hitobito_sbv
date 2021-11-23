# frozen_string_literal: true

#  Copyright (c) 2021, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class AddReportedMembersAttrsToGroups < ActiveRecord::Migration[6.0]
  def up
    add_column :groups, :reported_members, :integer, default: 0
    add_column :groups, :manually_counted_members, :boolean, default: false, null: false
  end
end
