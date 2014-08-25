class AddCertificateToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :certificate, :binary
  end
end
