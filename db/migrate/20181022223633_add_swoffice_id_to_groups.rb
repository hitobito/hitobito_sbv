class AddSwofficeIdToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :swoffice_id, :integer
  end
end
