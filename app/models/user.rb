class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable,
          :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  # ActiveStorage for avatar
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 100, 100 ]
  end

  validate :avatar_content_type
  validate :avatar_size

  # Associations
  has_one :vault, dependent: :destroy
  has_many :passwords, dependent: :destroy

  # 2FA association
  has_one :two_factor_auth, dependent: :destroy

  # Master password functionality
  has_secure_password :master_password, validations: false

  # Needed for 2FA
  attr_accessor :otp_code

  # Validations (combined from both implementations)
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, confirmation: true, length: { minimum: 8 }, on: :create
  validates :password_confirmation, presence: true, on: :create
  validates :master_password, length: { minimum: 8 }, allow_nil: true

  private

  def avatar_content_type
    return unless avatar.attached?
    unless avatar.content_type.in?(%w[image/png image/jpg image/jpeg image/gif image/webp])
      errors.add(:avatar, "must be a valid image format")
    end
  end

  def avatar_size
    return unless avatar.attached?
    if avatar.byte_size > 5.megabytes
      errors.add(:avatar, "should be less than 5MB")
    end
  end

  public

  # 2FA methods
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

  # Custom JWT revocation for logout all devices
  def jwt_revoked?(payload, _user)
    logged_out_at.present? && logged_out_at > Time.at(payload["iat"])
  end

  def avatar_url
    return nil unless avatar.attached?
    Rails.application.routes.url_helpers.rails_blob_path(avatar, only_path: true)
  end
end
