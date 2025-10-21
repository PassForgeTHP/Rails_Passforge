class Api::UsersController < ApplicationController
  before_action :authenticate_user!

  def verify_password
    if current_user.valid_password?(params[:password])
      render json: { success: true }, status: :ok
    else
      render json: { error: "Invalid password" }, status: :unauthorized
    end
  end
end
