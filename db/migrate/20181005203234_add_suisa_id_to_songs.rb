class AddSuisaIdToSongs < ActiveRecord::Migration[4.2]
  def change
    add_column :songs, :suisa_id, :integer
    add_index :songs, :suisa_id, unique: true
  end
end
