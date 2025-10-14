class ApplicationController < ActionController::API
  private

  def current_user
    return @current_user if @current_user

    auth_header = request.headers['Authorization']
    return nil unless auth_header

    token = auth_header.split(' ').last
    jwt_payload = JWT.decode(token, Rails.application.credentials.devise[:jwt_secret_key]).first
    user_id = jwt_payload['sub']
    @current_user = User.find_by(id: user_id)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
