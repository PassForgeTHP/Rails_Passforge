class AddEncryptionColumnsToVaults < ActiveRecord::Migration[8.0]
  def change
    add_column :vaults, :encrypted_data, :binary
    add_column :vaults, :encryption_iv, :string
    add_column :vaults, :encryption_tag, :string
    add_column :vaults, :version, :integer, default: 1
    add_column :vaults, :last_synced_at, :datetime
  end
end
