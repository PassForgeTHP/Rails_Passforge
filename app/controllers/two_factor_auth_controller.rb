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
end
