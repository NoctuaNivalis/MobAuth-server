class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :code, unique: true, null: false
      t.references :device, unqie: true, null: false, index: true

      t.timestamps
    end

    add_index "tokens", :code, unique: true
  end
end
