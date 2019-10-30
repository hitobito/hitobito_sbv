class RemoveReportedMembersFromGroups < ActiveRecord::Migration
  def change
    remove_column :groups, :reported_members, :integer
  end
end
