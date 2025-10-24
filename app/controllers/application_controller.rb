class ApplicationController < ActionController::API
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
end
