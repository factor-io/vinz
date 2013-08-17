class CreateConfigItemsGroupsTable < ActiveRecord::Migration
  def up
    create_table :config_items_groups, id: false do |t|
      t.integer :config_item_id
      t.integer :group_id
    end
  end

  def down
    drop_table :config_items_groups
  end
end
