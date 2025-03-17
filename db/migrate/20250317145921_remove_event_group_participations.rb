class RemoveEventGroupParticipations < ActiveRecord::Migration[7.1]
  def up
    drop_table :event_group_participations, if_exists: true
  end

  def down
  end
end
