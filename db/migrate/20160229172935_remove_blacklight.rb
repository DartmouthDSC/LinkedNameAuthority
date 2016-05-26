class RemoveBlacklight < ActiveRecord::Migration

	def self.up
		drop_table :searches
		drop_table :bookmarks
	end


	def self.down
	    create_table :searches do |t|
			t.text  :query_params
			t.integer :user_id
			t.string :user_type

			t.timestamps
	    end

	    add_index :searches, :user_id

		create_table :bookmarks do |t|
			t.integer :user_id, :null=>false
			t.string :user_type
			t.string :document_id
			t.string :title
			t.timestamps
	    end

	    add_column(:bookmarks, :document_type, :string)
    	add_index :bookmarks, :user_id
	end
end
