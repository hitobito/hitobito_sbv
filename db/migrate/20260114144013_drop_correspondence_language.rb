#  Copyright (c) 2026, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class DropCorrespondenceLanguage < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      UPDATE people
      SET language = correspondence_language
      WHERE correspondence_language IS NOT NULL;
    SQL
    remove_column :people, :correspondence_language
  end

  def down
    add_column :people, :correspondence_language
  end
end
