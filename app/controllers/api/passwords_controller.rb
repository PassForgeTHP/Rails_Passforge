module Api
  class PasswordsController < Api::ApplicationController
    # GET /api/passwords
    # Returns list of password entries for the current user
    #
    # Optional params:
    #   - search: string (search in title, username, or domain)
    #   - domain: string (filter by specific domain)
    #
    # Returns:
    #   - 200 OK: Array of password objects ordered by most recent
    #   - 401 Unauthorized: Missing or invalid JWT token
    #   - 500 Internal Server Error: Unexpected error
    def index
      @passwords = current_user.passwords.recent

      if params[:search].present?
        search_query = params[:search]
        @passwords = @passwords.where(
          "title ILIKE ? OR username ILIKE ? OR domain ILIKE ?",
          "%#{search_query}%", "%#{search_query}%", "%#{search_query}%"
        )
      end

      @passwords = @passwords.by_domain(params[:domain]) if params[:domain].present?

      render json: @passwords
    rescue StandardError => e
      Rails.logger.error "Password list error: #{e.class} - #{e.message}"
      render json: { error: 'Internal server error' }, status: :internal_server_error
    end

    # GET /api/passwords/:id
    # Returns a single password entry by ID
    #
    # Required params:
    #   - id: integer (password ID in URL path)
    #
    # Returns:
    #   - 200 OK: Password object with all fields
    #   - 404 Not Found: Password does not exist or does not belong to user
    #   - 401 Unauthorized: Missing or invalid JWT token
    def show
      @password = Password.find(params[:id])
      return render json: { error: 'Not found' }, status: :not_found unless @password.user_id == current_user.id
      render json: @password
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Not found' }, status: :not_found
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

    # PUT/PATCH /api/passwords/:id
    def update
    end

    private

    def password_params
      params.require(:password).permit(:title, :username, :password_encrypted, :domain, :notes)
    end
  end
end
