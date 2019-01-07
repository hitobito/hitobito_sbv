class AddPersonalDataUasgeToPeople < ActiveRecord::Migration
  def change
    add_column :people, :personal_data_usage, :boolean, default: false, null: false
  end
end
