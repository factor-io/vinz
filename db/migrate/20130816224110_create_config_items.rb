class CreateConfigItems < ActiveRecord::Migration
  def up
    create_table :config_items do |t|
      t.integer :organization_id
      t.string :name
      t.text :value
      t.timestamps
    end
  end

  def down
    drop_table :config_items
  end
end
