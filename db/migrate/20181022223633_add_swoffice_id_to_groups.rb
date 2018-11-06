class AddSwofficeIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :swoffice_id, :integer
  end
end
