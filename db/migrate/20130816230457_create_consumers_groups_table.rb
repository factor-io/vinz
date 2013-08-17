class CreateConsumersGroupsTable < ActiveRecord::Migration
  def up
    create_table :consumers_groups, id: false do |t|
      t.integer :consumer_id
      t.integer :group_id
    end
  end

  def down
    drop_table :consumers_groups
  end
end
