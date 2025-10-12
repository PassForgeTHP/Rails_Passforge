# PassForge Backend API Rails

This repository contains the **backend API** for PassForge, a secure password management application.
It provides user **authentication**, **authorization**, and **encrypted password** storage features built with Ruby on Rails.

### Overview 

PassForge’s backend is designed as a Rails API that handles:
- Secure user registration and authentication using Devise & JWT
- Encrypted password vault management for users
- Transactional emails powered by Mailjet (e.g. password reset, confirmation)

### Technologies Used

- Ruby on Rails – RESTful API architecture
- Devise – Authentication and password management
- JWT (JSON Web Token) – Stateless session handling
- Mailjet – Email delivery for authentication workflows

### Set up

```bash
# Clone the repository
git clone https://github.com/PassForgeTHP/Rails_Passforge.git

# Install dependencies
bundle install

# Set up the database
rails db:create db:migrate

# Run the server
rails s
```

### Environment Variables

Make sure to set up the following environment variables in your credentials file:

```ini
devise:
  jwt_secret_key: "your jwt secret key"

postgres:
  username: 
  password: 
  host: 

mailjet:
  api_key: "your api"
  secret_key: "your secret key"

```