class AddLoggedOutAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :logged_out_at, :datetime
  end
end
