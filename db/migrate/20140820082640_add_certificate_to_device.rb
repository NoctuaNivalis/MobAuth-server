class AddCertificateToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :certificate, :data, null: true
  end
end
