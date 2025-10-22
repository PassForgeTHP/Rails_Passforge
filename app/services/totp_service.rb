require "rqrcode"

class TotpService
  ISSUER = "PassForge"

  # Generate a new random TOTP secret
  # @return [String] a base32-encoded secret key compatible with TOTP authenticator apps
  def self.generate_secret
    ROTP::Base32.random
  end

  # Generate a provisioning URI for TOTP setup
  # @param secret [String] the base32-encoded TOTP secret
  # @param email [String] the user's email address
  # @return [String] otpauth:// URI compatible with TOTP authenticator apps
  def self.provisioning_uri(secret, email)
    totp = ROTP::TOTP.new(secret, issuer: ISSUER)
    totp.provisioning_uri(email)
  end

  # Generate a QR code SVG from a provisioning URI
  # @param uri [String] the otpauth:// provisioning URI
  # @return [String] SVG HTML string
  def self.generate_qr_code(uri)
    qrcode = RQRCode::QRCode.new(uri)

    svg = qrcode.as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 6,
      standalone: true
    )

    svg
  end

  # Verify a TOTP code against a secret
  # @param secret [String] the base32-encoded TOTP secret
  # @param code [String] the 6-digit code to verify
  # @param drift [Integer] time drift tolerance in 30-second intervals
  # @return [Boolean] true if the code is valid
  def self.verify_code(secret, code, drift: 1)
    totp = ROTP::TOTP.new(secret)
    totp.verify(code, drift_behind: drift, drift_ahead: drift).present?
  end

  # Generate backup codes for account recovery
  # @param count [Integer] number of backup codes to generate
  # @return [Hash] { codes: Array<String>, hashed_codes: Array<String> }
  def self.generate_backup_codes(count: 10)
    codes = []
    hashed_codes = []

    count.times do
      code = SecureRandom.alphanumeric(8).upcase
      codes << code
      hashed_codes << BCrypt::Password.create(code)
    end

    { codes: codes, hashed_codes: hashed_codes }
  end
end
