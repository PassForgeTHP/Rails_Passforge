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
    if current_user.update(jti: SecureRandom.uuid)
      render json: { message: "Logged out from all devices successfully" }, status: :ok
    else
      render json: { error: "Failed to logout" }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
