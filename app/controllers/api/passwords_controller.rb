module Api
  class PasswordsController < Api::ApplicationController
    include Pagy::Backend
    # GET /api/passwords
    # Returns paginated list of password entries for the current user
    #
    # Optional params:
    #   - search: string (search in title, username, or domain)
    #   - domain: string (filter by specific domain)
    #   - page: integer (page number, default: 1)
    #   - per_page: integer (items per page, default: 20)
    #
    # Returns:
    #   - 200 OK: JSON with data array and pagination metadata
    #   - 401 Unauthorized: Missing or invalid JWT token
    #   - 500 Internal Server Error: Unexpected error
    def index
      passwords_query = current_user.passwords.recent

      if params[:search].present?
        search_query = params[:search]
        passwords_query = passwords_query.where(
          "title ILIKE ? OR username ILIKE ? OR domain ILIKE ?",
          "%#{search_query}%", "%#{search_query}%", "%#{search_query}%"
        )
      end

      passwords_query = passwords_query.by_domain(params[:domain]) if params[:domain].present?

      @pagy, @passwords = pagy(passwords_query, items: params[:per_page] || 20)

      render json: {
        data: @passwords,
        pagination: {
          page: @pagy.page,
          per_page: @pagy.items,
          total: @pagy.count,
          total_pages: @pagy.pages
        }
      }
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
    # Updates an existing password entry
    #
    # Required params:
    #   - id: integer (password ID in URL path)
    #
    # Expected params:
    #   - title: string (optional, max 200 chars)
    #   - username: string (optional, max 255 chars)
    #   - password_encrypted: text (optional, client-side encrypted)
    #   - domain: string (optional, max 255 chars)
    #   - notes: text (optional, max 5000 chars)
    #
    # Returns:
    #   - 200 OK: Updated password object
    #   - 404 Not Found: Password does not exist or does not belong to user
    #   - 422 Unprocessable Entity: Validation errors
    #   - 401 Unauthorized: Missing or invalid JWT token
    def update
      @password = Password.find(params[:id])
      return render json: { error: 'Not found' }, status: :not_found unless @password.user_id == current_user.id

      if @password.update(password_params)
        render json: @password
      else
        render json: { errors: @password.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Not found' }, status: :not_found
    end

    # DELETE /api/passwords/:id
    def destroy
      @password = Password.find(params[:id])
      return render json: { error: 'Not found' }, status: :not_found unless @password.user_id == current_user.id

      @password.destroy
      render json: { message: 'Password deleted successfully' }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Not found' }, status: :not_found
    end

    private

    def password_params
      params.require(:password).permit(:title, :username, :password_encrypted, :domain, :notes)
    end
  end
end
