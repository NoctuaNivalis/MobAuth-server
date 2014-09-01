class CreateIntermediateCas < ActiveRecord::Migration
  def change
    create_table :intermediate_cas do |t|
      t.binary :keypair
      t.binary :certificate

      t.timestamps
    end
  end
end
