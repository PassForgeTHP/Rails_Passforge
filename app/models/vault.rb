before_save :method_name :method_name :method_nameclass Vault < ApplicationRecord
  belongs_to :user
  validates :user_id, uniqueness: true
end
