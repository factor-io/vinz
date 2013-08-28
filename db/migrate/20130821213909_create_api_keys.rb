class CreateApiKeys < ActiveRecord::Migration
  def up
    create_table :api_keys do |t|
      t.integer :key_owner_id
      t.string :key_owner_type
      t.string :key
      t.timestamps
    end
    add_index :api_keys, [:key_owner_id, :key_owner_type]
    add_index :api_keys, :key, name: 'api_keys_key_idx'
  end

  def down
    drop_table :api_keys
  end
end
