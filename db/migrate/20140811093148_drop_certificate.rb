class DropCertificate < ActiveRecord::Migration
  def change
    drop_table :certificates
  end
end
