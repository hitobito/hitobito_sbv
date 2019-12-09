class CreateGroupParticipations < ActiveRecord::Migration
  def change
    create_table :event_group_participations do |t|
      t.string :state, null: false

      t.references :event, null: false
      t.references :group, null: false

      t.timestamps null: false
    end

    add_index(:event_group_participations, [:event_id, :group_id], unique: true)
  end
end
