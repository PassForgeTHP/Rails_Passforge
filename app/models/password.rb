class Password < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :password_encrypted, presence: true
end
