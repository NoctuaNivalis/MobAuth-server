class RemoveDeviceFromToken < ActiveRecord::Migration
  def change
    remove_index :tokens, :device_id
    remove_column :tokens, :device_id
  end
end
