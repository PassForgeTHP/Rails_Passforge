class TwoFactorAuth < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :user_id, presence: true, uniqueness: true
  validates :secret_encrypted, presence: true
  validates :enabled, inclusion: { in: [ true, false ] }

  # Encrypt sensitive data using Rails built-in encryption
  # CRITICAL: These fields MUST be encrypted to prevent TOTP secret exposure
  # If an attacker gains database access, they could:
  # 1. Read TOTP secrets in plaintext
  # 2. Generate valid 2FA codes for any user
  # 3. Bypass 2FA protection completely
  #
  # Rails encrypts data using AES-256-GCM with keys from credentials file
  # See: config/credentials/development.yml.enc (or production.yml.enc)
  # encrypts :secret_encrypted
  # encrypts :backup_codes_encrypted

  # Check if a backup code is valid
  # @param code [String] the backup code to verify
  # @return [Boolean] true if the code matches one of the stored backup codes
  def valid_backup_code?(code)
    return false if backup_codes_encrypted.blank?

    codes = JSON.parse(backup_codes_encrypted)
    codes.any? { |hashed| BCrypt::Password.new(hashed) == code }
  rescue JSON::ParserError, BCrypt::Errors::InvalidHash
    false
  end

  # Mark a backup code as used by removing it from the list
  # @param code [String] the backup code to invalidate
  # @return [Boolean] true if the code was found and removed
  def use_backup_code!(code)
    return false if backup_codes_encrypted.blank?

    codes = JSON.parse(backup_codes_encrypted)
    index = codes.find_index { |hashed| BCrypt::Password.new(hashed) == code }

    return false if index.nil?

    codes.delete_at(index)
    update(backup_codes_encrypted: codes.to_json)
    true
  rescue JSON::ParserError, BCrypt::Errors::InvalidHash
    false
  end
end
