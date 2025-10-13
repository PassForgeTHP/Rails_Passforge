class ContactsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  # skip_before_action :verify_authenticity_token
  respond_to :json
  def create

    Rails.logger.info "📩 Params reçus: #{params.inspect}"
    email = params[:email]
    subject = params[:subject]
    content = params[:content]

    ContactMailer.contact_email(email, subject, content).deliver_now

    render json: { status: 'sent' }, status: :ok
  rescue => e
    Rails.logger.error "❌ Mail error: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}"
    render json: { status: 'error', message: e.message }, status: :unprocessable_entity
  end
end
