class AddUniqueIndexToUserRoles < ActiveRecord::Migration
  def change
    remove_index :roles_users, [:role_id, :user_id]
    add_index    :roles_users, [:role_id, :user_id], unique: true
  end
end
