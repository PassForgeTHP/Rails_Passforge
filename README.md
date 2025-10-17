# PassForge Backend API

Ruby on Rails REST API backend for PassForge password manager.

## What it does

This API provides authentication, user management, and encrypted password storage for the PassForge application.

### Core Features

- User registration and authentication (Devise + JWT)
- User profile management (name, email, avatar)
- Password reset via email (Mailjet)
- Contact form submission
- Health check endpoint for monitoring
- Storage of client-encrypted passwords with metadata

### Security Model

- Passwords are encrypted client-side before being sent to the server
- The server stores only encrypted data (password_encrypted field)
- The server never has access to master passwords or encryption keys
- Zero-knowledge architecture: the server cannot decrypt stored passwords

### Storage Options

The extension supports two storage modes:

**Local-only mode (default)**
- Encrypted vault stored in browser's IndexedDB
- No server synchronization
- Fast and private but no cross-device sync
- Risk: data loss if browser data is cleared

**Server-sync mode (via API endpoints)**
- Encrypted vault stored both locally (IndexedDB) and on server (PostgreSQL)
- Cross-device synchronization available
- Backup protection: vault can be recovered if browser data is lost
- Server stores encrypted data without ability to decrypt

## Tech Stack

- Rails 8.0.3 (API-only mode)
- PostgreSQL
- Devise + Devise-JWT for authentication
- Mailjet for transactional emails
- Rack-CORS for cross-origin requests

## API Endpoints

### Authentication
- `POST /users` - Register new user
- `POST /users/sign_in` - Login (returns JWT token)
- `DELETE /users/sign_out` - Logout
- `POST /users/password` - Request password reset
- `PUT /users/password` - Reset password with token

### User Management
- `GET /member-data` - Get current user profile (requires JWT)
- `PUT /users` - Update user profile (requires JWT)
- `DELETE /users` - Delete user account (requires JWT)

### Password Management (Encrypted Storage)
- `GET /api/passwords` - List all encrypted passwords for current user (with pagination and search)
- `GET /api/passwords/:id` - Get a specific encrypted password entry
- `POST /api/passwords` - Create new encrypted password entry
- `PUT /api/passwords/:id` - Update encrypted password entry
- `DELETE /api/passwords/:id` - Delete password entry

### Other
- `POST /contacts` - Submit contact form
- `GET /up` - Health check endpoint

## Local Setup

```bash
# Install dependencies
bundle install

# Create and migrate database
rails db:create db:migrate

# Seed demo users (optional)
rails db:seed

# Run development server
rails s
```

The API will be available at `http://localhost:3000`

## Environment Variables

Configure these in `config/credentials.yml.enc`:

```yaml
devise:
  jwt_secret_key: "your-jwt-secret-key"

mailjet:
  api_key: "your-mailjet-api-key"
  secret_key: "your-mailjet-secret-key"
```

For production deployment on Render:
- `DATABASE_URL` - PostgreSQL connection string (auto-configured)
- `RAILS_MASTER_KEY` - Rails credentials encryption key
- `FORCE_SEED` - Set to "true" to populate demo users

## Production Deployment

Deployed on Render with automatic deployments from the `dev` branch.

Production URL: `https://passforge-api.onrender.com`

Health check: `https://passforge-api.onrender.com/up`

## Demo Users

After running `rails db:seed`, the following demo accounts are available:

- Email: `alice@passforge.demo` / Password: `SecurePass123!`
- Email: `jean@passforge.demo` / Password: `SecurePass123!`
- Email: `paul@passforge.demo` / Password: `SecurePass123!`
- Email: `sophie@passforge.demo` / Password: `SecurePass123!`