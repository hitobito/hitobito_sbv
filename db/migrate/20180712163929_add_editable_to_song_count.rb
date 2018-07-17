class AddEditableToSongCount < ActiveRecord::Migration
  def change
    add_column :song_counts, :editable, :boolean, default: true, null: false
  end
end
