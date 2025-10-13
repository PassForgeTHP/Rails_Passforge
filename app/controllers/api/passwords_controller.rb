module Api
  class PasswordsController < Api::ApplicationController
    # GET /api/passwords
    def index
      @passwords = current_user.passwords
      render json: @passwords
    end

    # POST /api/passwords
    # Creates a new password entry for the current user
    #
    # Expected params:
    #   - title: string (required, max 200 chars)
    #   - username: string (optional, max 255 chars)
    #   - password_encrypted: text (required, client-side encrypted)
    #   - domain: string (optional, max 255 chars)
    #   - notes: text (optional, max 5000 chars)
    #
    # Returns:
    #   - 201 Created: Password object
    #   - 422 Unprocessable Entity: Validation errors
    #   - 401 Unauthorized: Missing or invalid JWT token
    #
    # Example request:
    #   POST /api/passwords
    #   Authorization: Bearer <jwt_token>
    #   {
    #     "password": {
    #       "title": "GitHub",
    #       "username": "user@example.com",
    #       "password_encrypted": "encrypted_data_here",
    #       "domain": "github.com",
    #       "notes": "Personal account"
    #     }
    #   }
    def create
      @password = current_user.passwords.build(password_params)

      if @password.save
        render json: @password, status: :created
      else
        render json: { errors: @password.errors.full_messages }, status: :unprocessable_entity
      end
    rescue StandardError => e
      Rails.logger.error "Password creation error: #{e.class} - #{e.message}"
      render json: { error: 'Internal server error' }, status: :internal_server_error
    end

    private

    def password_params
      params.require(:password).permit(:title, :username, :password_encrypted, :domain, :notes)
    end
  end
end
