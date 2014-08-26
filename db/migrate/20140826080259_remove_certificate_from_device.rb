class RemoveCertificateFromDevice < ActiveRecord::Migration
  def change
    remove_column :devices, :certificate, :binary
  end
end
