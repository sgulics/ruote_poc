class CreateRequestItems < ActiveRecord::Migration
  def change
    create_table :request_items do |t|
      t.string :state
      t.string :error_message
      t.integer :service1_id
      t.integer :service2_id
      t.boolean :monitored
      t.boolean :post_processed
      t.string :wfid
      t.timestamps
    end
  end
end
