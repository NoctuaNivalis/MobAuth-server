class AddRegistryNumberToUser < ActiveRecord::Migration
  def change
    add_column :users, :registry_number, :string
  end
end
