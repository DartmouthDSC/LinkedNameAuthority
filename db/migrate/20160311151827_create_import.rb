class CreateImport < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string    :load,         null: false
      t.timestamp :time_started, null: false
      t.timestamp :time_ended,   null: false
      t.boolean   :success,      null: false
      t.text      :status

      t.timestamps null: false
    end
  end
end
