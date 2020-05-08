class AddLohnsummeToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :buv_lohnsumme, :integer
    add_column :groups, :nbuv_lohnsumme, :integer
  end
end
