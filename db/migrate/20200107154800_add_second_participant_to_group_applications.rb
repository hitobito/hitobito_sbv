class AddSecondParticipantToGroupApplications < ActiveRecord::Migration[4.2]
  def change
    change_table :event_group_participations do |t|
      t.rename :state, :primary_state

      t.boolean :joint_participation, null: false, default: false
      t.string :secondary_state, null: false
      t.belongs_to :secondary_group
      t.boolean :secondary_group_terms_accepted, null: false, default: false
    end
  end
end
