class AddLohnsummeToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :buv_lohnsumme, :integer
    add_column :groups, :nbuv_lohnsumme, :integer
  end
end
