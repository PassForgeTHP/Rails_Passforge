class Users::RegistrationsController < Devise::RegistrationsController
  include Rails.application.routes.url_helpers
  respond_to :json

  before_action :authenticate_scope!, only: [:update, :destroy]

  def create
    build_resource(sign_up_params)

    if resource.save
      token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first

      render json: {
        message: 'Signed up successfully.',
        user: {
          id: resource.id,
          name: resource.name,
          email: resource.email,
          avatar: resource.avatar.attached? ? url_for(resource.avatar) : nil
        }
      }, status: :ok, headers: { 'Authorization' => "Bearer #{token}" }
    else
      render json: {
        message: 'Signup failed.',
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    user = current_user

    if user.update(account_update_params)
      render json: {
        message: 'Profile updated successfully.',
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          avatar: user.avatar.attached? ? url_for(user.avatar) : nil
        }
      }, status: :ok
    else
      render json: {
        message: 'Failed to update profile.',
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    user = current_user
    if user.destroy
      render json: { message: 'User account deleted successfully.' }, status: :ok
    else
      render json: { message: 'Failed to delete account.', errors: user.errors.full_messages },
             status: :unprocessable_entity
    end
  end
  
  private
  
  def sign_up_params
    params.require(:user).permit( :email, :password, :password_confirmation, :name)
  end


  def respond_with(resource, _opts = {})
    register_success && return if resource.persisted?

    register_failed
  end

  def register_success
    render json: {
      message: 'Signed up sucessfully.',
      user: resource
    }, status: :ok
  end

  def register_failed
    render json: { message: 'Something went wrong.' }, status: :unprocessable_entity
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password, :avatar)
  end
 
end