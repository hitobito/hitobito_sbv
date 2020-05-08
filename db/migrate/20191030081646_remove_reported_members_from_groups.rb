class RemoveReportedMembersFromGroups < ActiveRecord::Migration[4.2]
  def change
    remove_column :groups, :reported_members, :integer
  end
end
