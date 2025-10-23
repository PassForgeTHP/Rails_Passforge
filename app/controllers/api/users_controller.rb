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
    user_data = current_user.as_json(only: [ :id, :email, :name ], methods: [ :avatar_url ])
    user_data[:two_factor_enabled] = current_user.two_factor_auth&.enabled? || false
    render json: { user: user_data }, status: :ok
  end

  def update
    Rails.logger.info "JWT payload: #{request.env['warden-jwt_auth.token']&.inspect}"
    Rails.logger.info "Current user: #{current_user&.id}"
    Rails.logger.info "Update user params: #{user_params.inspect}"
    Rails.logger.info "Avatar present: #{user_params[:avatar].present?}"
    if current_user.update(user_params)
      puts "Update successful"
      render json: { user: current_user.as_json(only: [ :id, :email, :name ], methods: [ :avatar_url ]) }, status: :ok
    else
      puts "Update failed: #{current_user.errors.full_messages}"
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def logout_all
    begin
      puts "Logout all called, current_user: #{current_user.inspect}"
      if current_user.nil?
        puts "Current user is nil"
        render json: { error: "Not authenticated" }, status: :unauthorized
        return
      end
      success = current_user.update(logged_out_at: Time.current)
      puts "Update logged_out_at success: #{success}, errors: #{current_user.errors.full_messages}"
      if success
        puts "Logged out all devices for user #{current_user.id}"
        render json: { message: "Logged out from all devices successfully" }, status: :ok
      else
        puts "Failed to update logged_out_at for user #{current_user.id}: #{current_user.errors.full_messages}"
        render json: { error: "Failed to logout" }, status: :unprocessable_entity
      end
    rescue => e
      puts "Exception in logout_all: #{e.message}"
      puts e.backtrace.join("\n")
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar)
  end
end
