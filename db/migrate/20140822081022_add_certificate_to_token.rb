class AddCertificateToToken < ActiveRecord::Migration
  def change
    add_column :tokens, :certificate, :binary
  end
end
