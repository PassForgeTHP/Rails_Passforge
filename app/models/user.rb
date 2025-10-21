class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  # ActiveStorage for avatar
  has_one_attached :avatar

  # 2FA association
  has_one :two_factor_auth, dependent: :destroy

  # Needed for 2FA
  attr_accessor :otp_code

  def self.generate_otp_secret
    ROTP::Base32.random_secret
  end

  def otp_provisioning_uri(account, issuer: nil)
    ROTP::TOTP.new(otp_secret, issuer: issuer).provisioning_uri(account)
  end

  def validate_and_consume_otp!(code)
    totp = ROTP::TOTP.new(otp_secret)
    totp.verify(code, drift_behind: 15) # Allow 15 seconds drift
  end
end
