class Users::SessionsController < Devise::SessionsController
  include Rails.application.routes.url_helpers
  respond_to :json

  before_action :authenticate_user!, only: [ :verify_password ]

  private

  def respond_with(_resource, _opts = {})
    if resource.persisted?
      # Check if 2FA is enabled for this user
      if resource.two_factor_auth&.enabled?
        # Store user_id in session for subsequent 2FA verification
        session[:pending_2fa_user_id] = resource.id

        # Sign out the user immediately (they will sign in after 2FA)
        sign_out(resource)

        render json: {
          requires_2fa: true,
          message: "Please enter your 2FA code to complete login"
        }, status: :ok
      else
        # Normal login without 2FA
        render json: {
          message: "You are logged in.",
          user: {
            id: resource.id,
            email: resource.email,
            name: resource.name,
            avatar: resource.avatar.attached? ? url_for(resource.avatar) : nil
          }
        }, status: :ok
      end
    else
      render json: { message: "Invalid email or password." }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    log_out_success && return if current_user

    log_out_failure
  end

  def log_out_success
    render json: { message: "You are logged out." }, status: :ok
  end

  def log_out_failure
    render json: { message: "Hmm nothing happened." }, status: :unauthorized
  end

  def verify_password
    if current_user.valid_password?(params[:password])
      render json: { success: true }, status: :ok
    else
      render json: { error: "Invalid password" }, status: :unauthorized
    end
  end
end
