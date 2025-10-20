module Api
  class MasterPasswordsController < ApplicationController
    before_action :authenticate_user!

    def show
      user = current_user
      render json: { has_master_password: user.master_password_digest.present? }
    end

    def create
      user = current_user

      if user.master_password_digest.present?
        return render json: { error: 'Master password already set' }, status: :unprocessable_entity
      end

      if user.update(master_password_params)
        render json: { message: 'Master password set successfully' }, status: :ok
      else
        render json: { error: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      user = current_user
      old_password = params[:current_master_password]

      unless user.authenticate_master_password(old_password)
        return render json: { error: 'Invalid current master password' }, status: :unauthorized
      end

      if user.update(master_password_params)
        render json: { message: 'Master password updated successfully' }, status: :ok
      else
        render json: { error: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def verify
      user = current_user

      unless user.authenticate_master_password(params[:master_password])
        return render json: { success: false, error: 'Invalid master password' }, status: :unauthorized
      end

      render json: { success: true, message: 'Vault unlocked' }, status: :ok
    end

    private

    def master_password_params
      params.require(:user).permit(:master_password)
    end
  end
end
