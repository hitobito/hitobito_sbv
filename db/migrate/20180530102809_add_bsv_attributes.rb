class AddBsvAttributes < ActiveRecord::Migration
  def change
    add_column :groups, :vereinssitz, :string
    add_column :groups, :founding_year, :integer
    add_column :groups, :correspondence_language, :string, limit: 5
    add_column :groups, :besetzung, :string
    add_column :groups, :klasse, :string
    add_column :groups, :unterhaltungsmusik, :string
    add_column :groups, :subventionen, :string
    add_column :groups, :reported_members , :integer

    add_column :people, :profession, :string
    add_column :people, :correspondence_language, :string, limit: 5
  end
end
