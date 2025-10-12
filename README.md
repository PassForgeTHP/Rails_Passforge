# PassForge API

Rails API backend for PassForge password manager application.

## Tech Stack

- **Ruby** 3.4.2
- **Rails** 8.0.3
- **PostgreSQL** (database)
- **Devise** (authentication)
- **Devise-JWT** (token-based API authentication)

## Prerequisites

- Ruby 3.4.2
- PostgreSQL
- Bundler

## Local Development Setup

### 1. Clone the repository

```bash
git clone https://github.com/PassForgeTHP/Rails_Passforge.git
cd Rails_Passforge
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Setup master key

Create `config/master.key` with your Rails master key:

```bash
echo "your_master_key_here" > config/master.key
```

### 4. Setup database

```bash
# Create databases
rails db:create

# Run migrations
rails db:migrate

# Seed database (optional)
rails db:seed
```

### 5. Start the server

```bash
rails server
```

API will be available at `http://localhost:3000`

## Running Tests

```bash
rails test
```

## Deployment on Render

This application is configured for deployment on [Render](https://render.com/).

### Automatic Deployment

The `render.yaml` file at the root configures:
- PostgreSQL database (free tier)
- Web service running Rails API (free tier)

### Steps to Deploy

1. **Push your code** to GitHub

2. **Create a new Web Service** on Render:
   - Connect your GitHub repository
   - Render will automatically detect `render.yaml`

3. **Set environment variables** in Render dashboard:
   - `RAILS_MASTER_KEY`: Your Rails master key

   All other variables are configured automatically via `render.yaml`.

4. **Deploy**:
   - Render will automatically:
     - Create the PostgreSQL database
     - Install dependencies
     - Run migrations
     - Start the Puma server

### Manual Configuration (Alternative)

If not using `render.yaml`:

**Build Command:**
```bash
bundle install && bundle exec rails db:migrate
```

**Start Command:**
```bash
bundle exec puma -C config/puma.rb
```

**Environment Variables:**
- `RAILS_ENV=production`
- `RAILS_MASTER_KEY=<your_master_key>`
- `DATABASE_URL=<automatically_provided_by_render>`
- `RAILS_LOG_TO_STDOUT=enabled`
- `RAILS_SERVE_STATIC_FILES=enabled`

## API Endpoints

Authentication endpoints:
- `POST /api/users` - User registration
- `POST /api/users/sign_in` - User login
- `DELETE /api/users/sign_out` - User logout

Vault endpoints:
- Coming soon...

## Project Structure

```
app/
├── controllers/     # API controllers
├── models/         # ActiveRecord models
└── mailers/        # Email templates

config/
├── database.yml    # Database configuration
├── routes.rb       # API routes
└── initializers/   # App configuration

db/
├── migrate/        # Database migrations
└── schema.rb       # Current database schema
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests
4. Submit a pull request

## License

Private project - All rights reserved
