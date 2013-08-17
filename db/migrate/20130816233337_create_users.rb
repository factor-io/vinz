class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.integer :organization_id
      t.string :username
      t.string :password
      t.string :api_key
      t.string :role
      t.timestamps
    end
  end

  def down
  end
end
