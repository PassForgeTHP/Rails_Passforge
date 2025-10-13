class Password < ApplicationRecord
  # Associations
  belongs_to :user # Automatically validates presence of user

  # Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :password_encrypted, presence: true
end
