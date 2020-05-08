class RemoveDefaultTimestamps < ActiveRecord::Migration[4.2]
  def change
    change_column_default :concerts, :created_at, nil
    change_column_default :concerts, :updated_at, nil
  end
end
