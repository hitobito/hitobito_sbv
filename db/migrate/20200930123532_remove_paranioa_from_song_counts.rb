class RemoveParanioaFromSongCounts < ActiveRecord::Migration[6.0]
  def change
    remove_index :song_counts, :column => :deleted_at
    remove_column :song_counts, :deleted_at
  end
end
