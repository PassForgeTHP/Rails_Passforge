class Users::SessionsController < Devise::SessionsController
  include Rails.application.routes.url_helpers
  respond_to :json

  private

  def respond_with(_resource, _opts = {})
    render json: {
      message: 'You are logged in.',
      user: {
        id: resource.id,
        email: resource.email,
        name: resource.name,
        avatar: resource.avatar.attached? ? url_for(resource.avatar) : nil
      }
    }, status: :ok
  end

  def respond_to_on_destroy
    log_out_success && return if current_user

    log_out_failure
  end

  def log_out_success
    render json: { message: 'You are logged out.' }, status: :ok
  end

  def log_out_failure
    render json: { message: 'Hmm nothing happened.' }, status: :unauthorized
  end
end