class AddSecondaryParentsToGroups < ActiveRecord::Migration
  def change
    change_table :groups do |t|
      t.integer :secondary_parent_id
      t.integer :tertiary_parent_id
    end
  end
end
