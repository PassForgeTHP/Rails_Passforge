module Api
  module Auth
    module TwoFactor
      class TwoFactorAuthController < ApplicationController
        before_action :authenticate_user!, except: [:verify_login]

        # POST /api/auth/two_factor/setup
        # Generate a new TOTP secret and QR code for the user
        def setup
          secret = TotpService.generate_secret
          uri = TotpService.provisioning_uri(secret, current_user.email)
          qr_code = TotpService.generate_qr_code(uri)

          render json: {
            qr_code: "data:image/png;base64,#{qr_code}",
            secret: secret,
            message: 'Scan the QR code with your authenticator app (2FAS, Google Authenticator, etc.)'
          }, status: :ok
        rescue => e
          render json: { error: 'Failed to setup 2FA', details: e.message }, status: :unprocessable_entity
        end

        # POST /api/auth/two_factor/verify
        # Verify the TOTP code and enable 2FA for the user
        def verify
          secret = params[:secret]
          code = params[:code]

          unless secret.present? && code.present?
            return render json: { error: 'Secret and code are required' }, status: :bad_request
          end

          unless TotpService.verify_code(secret, code)
            return render json: { error: 'Invalid verification code' }, status: :unauthorized
          end

          # Generate backup codes
          backup_data = TotpService.generate_backup_codes
          hashed_codes = backup_data[:hashed_codes].to_json

          # Create or update TwoFactorAuth record
          two_factor_auth = current_user.two_factor_auth || current_user.build_two_factor_auth
          two_factor_auth.assign_attributes(
            secret_encrypted: secret,
            enabled: true,
            backup_codes_encrypted: hashed_codes
          )

          if two_factor_auth.save
            render json: {
              message: '2FA has been successfully enabled',
              backup_codes: backup_data[:codes],
              warning: 'Save these backup codes in a secure location. They will not be shown again.'
            }, status: :ok
          else
            render json: { error: 'Failed to enable 2FA', details: two_factor_auth.errors.full_messages }, status: :unprocessable_entity
          end
        rescue => e
          render json: { error: 'Failed to verify 2FA', details: e.message }, status: :unprocessable_entity
        end

        # DELETE /api/auth/two_factor/disable
        # Disable and remove 2FA for the current user
        def disable
          two_factor_auth = current_user.two_factor_auth

          unless two_factor_auth
            return render json: { error: '2FA is not enabled for this account' }, status: :bad_request
          end

          if two_factor_auth.destroy
            render json: { message: '2FA has been successfully disabled' }, status: :ok
          else
            render json: { error: 'Failed to disable 2FA' }, status: :unprocessable_entity
          end
        rescue => e
          render json: { error: 'Failed to disable 2FA', details: e.message }, status: :unprocessable_entity
        end

        # POST /api/auth/two_factor/verify_login
        # Verify 2FA code during login and complete authentication
        def verify_login
          user_id = session[:pending_2fa_user_id]

          unless user_id
            return render json: { error: 'No pending 2FA verification. Please login first.' }, status: :unauthorized
          end

          user = User.find_by(id: user_id)
          unless user
            session.delete(:pending_2fa_user_id)
            return render json: { error: 'User not found' }, status: :not_found
          end

          two_factor_auth = user.two_factor_auth
          unless two_factor_auth&.enabled?
            session.delete(:pending_2fa_user_id)
            return render json: { error: '2FA is not enabled for this account' }, status: :bad_request
          end

          code = params[:code]
          backup_code = params[:backup_code]

          verified = false

          if code.present?
            verified = TotpService.verify_code(two_factor_auth.secret_encrypted, code)
          elsif backup_code.present?
            verified = verify_and_use_backup_code(two_factor_auth, backup_code)
          else
            return render json: { error: 'Code or backup_code is required' }, status: :bad_request
          end

          unless verified
            return render json: { error: 'Invalid verification code' }, status: :unauthorized
          end

          session.delete(:pending_2fa_user_id)
          sign_in(user)

          render json: {
            message: 'Login successful',
            user: {
              id: user.id,
              email: user.email,
              name: user.name,
              avatar: user.avatar.attached? ? url_for(user.avatar) : nil
            }
          }, status: :ok
        rescue => e
          render json: { error: 'Failed to verify 2FA', details: e.message }, status: :unprocessable_entity
        end

        private

        # Verify a backup code and mark it as used
        def verify_and_use_backup_code(two_factor_auth, backup_code)
          return false if two_factor_auth.backup_codes_encrypted.blank?

          codes = JSON.parse(two_factor_auth.backup_codes_encrypted)
          index = codes.find_index { |hashed| BCrypt::Password.new(hashed) == backup_code }

          return false if index.nil?

          codes.delete_at(index)
          two_factor_auth.update(backup_codes_encrypted: codes.to_json)
          true
        rescue JSON::ParserError, BCrypt::Errors::InvalidHash
          false
        end
      end
    end
  end
end
