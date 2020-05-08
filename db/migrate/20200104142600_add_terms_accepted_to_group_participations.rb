class AddTermsAcceptedToGroupParticipations < ActiveRecord::Migration[4.2]
  def change
    change_table :event_group_participations do |t|
      t.boolean :terms_accepted, null: false, default: false
    end
  end
end
