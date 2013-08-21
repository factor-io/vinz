class CreateConsumers < ActiveRecord::Migration
  def up
    create_table :consumers do |t|
      t.integer :organization_id
      t.string :name
      t.timestamps
    end
  end

  def down
    drop_table :consumers
  end
end
