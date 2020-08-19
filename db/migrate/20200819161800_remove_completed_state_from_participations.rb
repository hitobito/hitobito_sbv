# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class RemoveCompletedStateFromParticipations < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      UPDATE event_group_participations
      SET primary_state = 'terms_accepted'
      WHERE primary_state = 'completed'
    SQL

    execute <<~SQL
      UPDATE event_group_participations
      SET secondary_state = 'terms_accepted'
      WHERE secondary_state = 'completed'
    SQL
  end

  def down
    # nothing to be done here
  end
end
