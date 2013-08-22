class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.integer :organization_id
      t.string :username
      t.text :password
      t.string :role
      t.timestamps
    end
  end

  def down
  end
end
