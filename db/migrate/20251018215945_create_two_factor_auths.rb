class CreateTwoFactorAuths < ActiveRecord::Migration[8.0]
  def change
    create_table :two_factor_auths do |t|
      t.references :user, null: false, foreign_key: true
      t.text :secret_encrypted
      t.boolean :enabled
      t.text :backup_codes_encrypted

      t.timestamps
    end
  end
end
