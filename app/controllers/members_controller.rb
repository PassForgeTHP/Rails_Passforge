class MembersController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: {
      message: "If you see this, you're in!",
      user: {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email,
        avatar: current_user.avatar.attached? ? url_for(current_user.avatar) : nil,
        two_factor_enabled: current_user.two_factor_auth&.enabled? || false
      }
    }
  end
end
