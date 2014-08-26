class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.references :device, index: true
      t.references :intermediate_ca, index: true
      t.binary :crt, index: true
      t.datetime :revoked_at

      t.timestamps
    end
  end
end
