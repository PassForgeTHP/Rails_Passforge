class CreatePasswords < ActiveRecord::Migration[8.0]
  def change
    create_table :passwords do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :username
      t.text :password_encrypted, null: false
      t.string :domain
      t.text :notes

      t.timestamps
    end
  end
end
