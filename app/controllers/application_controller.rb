class ApplicationController < ActionController::API
  before_action :log_jwt_payload, if: -> { request.headers['Authorization'].present? }

  # Handle JWT decode errors (invalid token format)
  rescue_from JWT::DecodeError do |e|
    Rails.logger.error "❌ [JWT ERROR] Decode error: #{e.message}"
    render json: { error: 'Invalid token format' }, status: :unauthorized
  end

  # Handle JWT expired signature
  rescue_from JWT::ExpiredSignature do |e|
    Rails.logger.error "❌ [JWT ERROR] Token expired: #{e.message}"
    render json: { error: 'Token expired' }, status: :unauthorized
  end

  private

  def log_jwt_payload
    token = request.headers['Authorization']&.split(' ')&.last
    return unless token

    begin
      # Decode without verification to see the payload
      payload = JWT.decode(token, nil, false).first
      Rails.logger.debug "🔍 [JWT PAYLOAD] #{payload.inspect}"
      Rails.logger.debug "🔍 [JWT] Token sub (user_id): #{payload['sub']}"

      # Check if there's a session interfering
      Rails.logger.debug "🔍 [SESSION] warden.user.user.key: #{session['warden.user.user.key'].inspect}"
      Rails.logger.debug "🔍 [COOKIES] #{request.cookies.inspect}"
    rescue => e
      Rails.logger.error "❌ [JWT DECODE ERROR] #{e.message}"
    end
  end
end
