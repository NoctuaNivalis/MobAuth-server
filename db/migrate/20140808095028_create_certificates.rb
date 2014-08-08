class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.references :user, index: true
      t.references :device, index: true

      t.timestamps
    end
  end
end
