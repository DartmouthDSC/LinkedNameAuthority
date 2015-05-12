class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :name, :string
    add_column :users, :netid, :string
    add_column :users, :realm, :string
    add_column :users, :affil, :string

    add_index :users, :netid,     unique: true
    add_index :users, :uid,       unique: true
  end
end
