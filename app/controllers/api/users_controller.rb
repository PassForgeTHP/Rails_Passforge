class Api::UsersController < ApplicationController
  before_action :authenticate_user!

  def verify_password
    if current_user.valid_password?(params[:password])
      render json: { success: true }, status: :ok
    else
      render json: { error: "Invalid password" }, status: :unauthorized
    end
  end

  def logout_all
    Rails.logger.info "Logout all called for user: #{current_user&.id}"
    if current_user.update(jti: SecureRandom.uuid)
      Rails.logger.info "JTI updated successfully for user #{current_user.id}"
      render json: { message: "Logged out from all devices successfully" }, status: :ok
    else
      Rails.logger.error "Failed to update JTI for user #{current_user.id}: #{current_user.errors.full_messages}"
      render json: { error: "Failed to logout" }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Exception in logout_all: #{e.message}"
    render json: { error: e.message }, status: :internal_server_error
  end
end
