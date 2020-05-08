class AddParademusicToGroupParticipations < ActiveRecord::Migration[4.2]
  def change
    change_table :event_group_participations do |t|
      t.string :parade_music
    end
  end
end
