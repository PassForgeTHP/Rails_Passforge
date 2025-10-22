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
    puts "Logout all called, current_user: #{current_user.inspect}"
    puts "User columns: #{User.column_names}"
    if current_user.nil?
      puts "Current user is nil"
      render json: { error: "Not authenticated" }, status: :unauthorized
      return
    end
    new_jti = SecureRandom.uuid
    puts "Updating JTI to #{new_jti}"
    begin
      success = current_user.update(jti: new_jti)
      puts "Update success: #{success}"
      if success
        puts "JTI updated successfully for user #{current_user.id}"
        render json: { message: "Logged out from all devices successfully" }, status: :ok
      else
        puts "Failed to update JTI for user #{current_user.id}: #{current_user.errors.full_messages}"
        render json: { error: "Failed to logout" }, status: :unprocessable_entity
      end
    rescue => e
      puts "Exception in logout_all: #{e.message}"
      puts e.backtrace
      render json: { error: e.message }, status: :internal_server_error
    end
  end
end
