class ModifyCertificateOnToken < ActiveRecord::Migration
  def change
    remove_column :tokens, :certificate, :binary
    add_column :tokens, :certificate_id, :integer
  end
end
