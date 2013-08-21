class CreateApiKeys < ActiveRecord::Migration
  def up
    create_table :api_keys do |t|
      t.integer :key_owner_id
      t.string :key_owner_type
      t.string :key
      t.timestamps
    end
  end

  def down
    drop_table :api_keys
  end
end
