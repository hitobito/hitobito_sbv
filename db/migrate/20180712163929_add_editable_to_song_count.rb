class AddEditableToSongCount < ActiveRecord::Migration[4.2]
  def change
    add_column :song_counts, :editable, :boolean, default: true, null: false
  end
end
