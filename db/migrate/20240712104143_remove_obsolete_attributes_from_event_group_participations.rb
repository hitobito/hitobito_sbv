class RemoveObsoleteAttributesFromEventGroupParticipations < ActiveRecord::Migration[6.1]
  def change
    remove_column :event_group_participations, :preferred_play_day_1, :integer
    remove_column :event_group_participations, :preferred_play_day_2, :integer
    remove_column :event_group_participations, :terms_accepted, :boolean
    remove_column :event_group_participations, :secondary_group_terms_accepted, :boolean
  end
end
