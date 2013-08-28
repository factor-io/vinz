class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.integer :organization_id
      t.string :username
      t.text :password
      t.string :role
      t.timestamps
    end
    add_index :users, :organization_id, name: 'users_organization_id_idx'
  end

  def down
  end
end
