class TwoFactorAuthController < ApplicationController
  before_action :authenticate_user!

  def setup
    render json: { message: "Test successful" }
  end

  def enable
    user = current_user
    if user.validate_and_consume_otp!(params[:otp_code])
      user.otp_required_for_login = true
      user.save!
      render json: { success: true, user: user.as_json(only: [ :id, :email, :name, :two_factor_enabled ]) }
    else
      render json: { success: false, error: "Invalid OTP code." }, status: :unprocessable_entity
    end
  end

  def verify_login
    user_id = session[:pending_2fa_user_id]
    user = User.find_by(id: user_id)

    if user && user.validate_and_consume_otp!(params[:otp_code])
      session.delete(:pending_2fa_user_id)
      sign_in(user)
      render json: {
        message: "Login successful",
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          avatar: user.avatar.attached? ? url_for(user.avatar) : nil
        }
      }, status: :ok
    else
      render json: { error: "Invalid 2FA code" }, status: :unauthorized
    end
  end
end
