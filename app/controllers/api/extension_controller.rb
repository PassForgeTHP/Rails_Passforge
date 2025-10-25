class Api::ExtensionController < ApplicationController
  before_action :authenticate_user!

  # POST /api/extension/token
  # Generates a fresh JWT token for browser extension linking
  def generate_token
    # Warden's jwt strategy will automatically generate and set the token
    # We just need to return success with user info
    render json: {
      message: "Token generated successfully",
      user: {
        id: current_user.id,
        email: current_user.email,
        name: current_user.name
      }
    }, status: :ok
  end

  # GET /api/extension/verify_token
  # Verifies if the provided JWT token is valid
  # Simpler endpoint for extension that doesn't depend on session
  def verify_token
    # If we reach here, authenticate_user! has already validated the token
    render json: {
      valid: true,
      user: {
        id: current_user.id,
        email: current_user.email,
        name: current_user.name
      }
    }, status: :ok
  rescue => e
    render json: {
      valid: false,
      error: "Invalid or expired token"
    }, status: :unauthorized
  end
end
