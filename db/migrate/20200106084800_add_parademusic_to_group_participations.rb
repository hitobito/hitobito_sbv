class AddParademusicToGroupParticipations < ActiveRecord::Migration
  def change
    change_table :event_group_participations do |t|
      t.string :parade_music
    end
  end
end
