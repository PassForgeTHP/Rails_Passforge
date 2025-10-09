class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

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
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
  end
end