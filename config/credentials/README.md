# Rails Credentials Configuration

## Overview

This application uses Rails encrypted credentials to store sensitive configuration values.

## Required Credentials for 2FA

The Two-Factor Authentication feature requires encryption keys to protect TOTP secrets in the database.

### Development Environment

Edit development credentials:
```bash
EDITOR="nano" rails credentials:edit --environment development
```

Add the following configuration:
```yaml
devise:
  jwt_secret_key: <your-jwt-secret-key>

active_record_encryption:
  primary_key: <generated-by-rails-db-encryption-init>
  deterministic_key: <generated-by-rails-db-encryption-init>
  key_derivation_salt: <generated-by-rails-db-encryption-init>
```

### Production Environment

Edit production credentials:
```bash
EDITOR="nano" rails credentials:edit --environment production
```

Use the same structure as development, but with different keys.

## Generating Encryption Keys

To generate new encryption keys:
```bash
rails db:encryption:init
```

This will output three keys that should be added to your credentials file.

## Why Encryption is Critical for 2FA

The `TwoFactorAuth` model stores TOTP secrets that generate time-based authentication codes.

**Without encryption:**
- TOTP secrets stored in plaintext in database
- Database breach = attacker can generate valid 2FA codes
- Complete 2FA bypass

**With encryption (AES-256-GCM):**
- TOTP secrets encrypted before storage
- Database breach = unusable encrypted data
- Attacker needs both database AND encryption keys

## Security Best Practices

1. **Never commit** `config/credentials/*.key` files to git (already in .gitignore)
2. **Rotate keys** if you suspect compromise
3. **Use different keys** for development, staging, and production
4. **Store production keys** in your deployment platform's secret manager
   - Render: Environment Variables
   - Heroku: Config Vars
   - AWS: Secrets Manager

## Troubleshooting

### Error: "Missing Active Record encryption credential"

This means encryption keys are not configured in credentials.

**Solution:**
```bash
# Generate keys
rails db:encryption:init

# Add keys to credentials
EDITOR="nano" rails credentials:edit --environment development
```

### Error: "Invalid key" or decryption fails

Keys may have been rotated or corrupted.

**Solution:**
- Check that credentials file is using correct key file
- Verify `config/credentials/development.key` exists and matches
- Re-encrypt data if keys were intentionally changed (see Rails guides)
