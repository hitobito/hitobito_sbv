class AddTermsAcceptedToGroupParticipations < ActiveRecord::Migration
  def change
    change_table :event_group_participations do |t|
      t.boolean :terms_accepted, null: false, default: false
    end
  end
end
