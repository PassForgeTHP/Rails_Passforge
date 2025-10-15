class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable,
         :jwt_authenticatable,
	       jwt_revocation_strategy: JwtDenylist

  has_one_attached :avatar       
  has_one :vault, dependent: :destroy
  has_many :passwords, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, confirmation: true, length: { minimum: 8 }, on: :create
  validates :password_confirmation, presence: true, on: :create
end
