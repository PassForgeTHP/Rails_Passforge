class CreateTwoFactorAuths < ActiveRecord::Migration[8.0]
  def change
    create_table :two_factor_auths do |t|
      # Foreign key to users table - one 2FA config per user
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      # Encrypted TOTP secret (base32 encoded)
      t.text :secret_encrypted, null: false

      # Whether 2FA is currently active for this user
      t.boolean :enabled, default: false, null: false

      # Encrypted backup codes for account recovery (JSON array)
      t.text :backup_codes_encrypted

      t.timestamps
    end
  end
end
