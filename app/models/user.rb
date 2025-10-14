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
end
