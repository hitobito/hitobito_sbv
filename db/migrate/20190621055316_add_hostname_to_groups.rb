class AddHostnameToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :hostname, :string

    add_index :groups, :hostname, unique: true
  end
end
