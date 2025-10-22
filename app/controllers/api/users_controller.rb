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
    current_user.update(jti: SecureRandom.uuid)
    render json: { message: "Logged out from all devices successfully" }, status: :ok
  end
end
