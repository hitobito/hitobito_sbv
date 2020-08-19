class AddDeletedAtToConcertsAndSongcounts < ActiveRecord::Migration[6.0]
  def change
    add_column :concerts, :deleted_at, :datetime
    add_index  :concerts, :deleted_at

    add_column :song_counts, :deleted_at, :datetime
    add_index  :song_counts, :deleted_at
  end
end
