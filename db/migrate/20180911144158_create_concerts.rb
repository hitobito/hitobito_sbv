class CreateConcerts < ActiveRecord::Migration[4.2]
  def change
    create_table :concerts do |t|
      t.string :name, null: false

      t.belongs_to :verein, null: false
      t.belongs_to :mitgliederverband, index: true
      t.belongs_to :regionalverband, index: true
      t.belongs_to :song_census

      t.date :performed_at
      t.integer :year, null: false
      t.boolean :editable, default: true, null: false
    end

    remove_reference :song_counts, :verein
    remove_reference :song_counts, :mitgliederverband
    remove_reference :song_counts, :regionalverband
    remove_reference :song_counts, :song_census

    remove_column :song_counts, :editable

    remove_index :song_counts, column: [:song_id, :verein_id, :year]

    add_reference :song_counts, :concert, foreign_key: true
  end
end
