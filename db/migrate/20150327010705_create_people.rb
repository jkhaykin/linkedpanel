class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
      t.string :url
      t.string :headline
      t.integer :user_id

      t.timestamps
    end
  end
end
