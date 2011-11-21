class CreateDeliveries < ActiveRecord::Migration
  def self.up
    create_table :deliveries do |t|
      t.integer :supplier_id
      t.integer :order_id
      t.boolean :shipped

      t.timestamps
    end
  end

  def self.down
    drop_table :deliveries
  end
end