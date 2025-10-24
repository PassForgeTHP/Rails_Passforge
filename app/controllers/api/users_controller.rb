class Api::UsersController < ApplicationController
  before_action :authenticate_user!

  def verify_password
    if current_user.valid_password?(params[:password])
      render json: { success: true }, status: :ok
    else
      render json: { error: "Invalid password" }, status: :unauthorized
    end
  end

  def show
    Rails.logger.debug "🔍 [MEMBER-DATA] Authorization header: #{request.headers['Authorization']}"
    Rails.logger.debug "🔍 [MEMBER-DATA] Current user: #{current_user.inspect}"

    user_data = current_user.as_json(only: [ :id, :email, :name ], methods: [ :avatar_url ])
    user_data[:two_factor_enabled] = current_user.two_factor_auth&.enabled? || false
    render json: { user: user_data }, status: :ok
  end

  def update
    if current_user.update(user_params)
      render json: { user: current_user.as_json(only: [ :id, :email, :name ], methods: [ :avatar_url ]) }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def logout_all
    begin
      if current_user.nil?
        render json: { error: "Not authenticated" }, status: :unauthorized
        return
      end
      success = current_user.update(logged_out_at: Time.current)
      if success
        render json: { message: "Logged out from all devices successfully" }, status: :ok
      else
        render json: { error: "Failed to logout" }, status: :unprocessable_entity
      end
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar)
  end
end
