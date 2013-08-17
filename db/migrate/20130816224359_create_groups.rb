class CreateGroups < ActiveRecord::Migration
  def up
    create_table :groups do |t|
      t.integer :organization_id
      t.string :name
      t.timestamps
    end
  end

  def down
    drop_table :groups
  end
end
