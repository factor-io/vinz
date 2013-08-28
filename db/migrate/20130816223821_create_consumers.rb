class CreateConsumers < ActiveRecord::Migration
  def up
    create_table :consumers do |t|
      t.integer :organization_id
      t.string :name
      t.timestamps
    end
    add_index :consumers, :organization_id, name: 'consumers_organization_id_idx'
  end

  def down
    drop_table :consumers
  end
end
