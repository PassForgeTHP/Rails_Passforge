class AddMasterPasswordDigestToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :master_password_digest, :string
  end
end
