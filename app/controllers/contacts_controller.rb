class ContactsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :verify_authenticity_token
  respond_to :json
  def create
    email = params[:email]
    subject = params[:subject]
    content = params[:content]

    ContactMailer.contact_email(email, subject, content).deliver_now

    render json: { status: 'sent' }, status: :ok
  rescue => e
    render json: { status: 'error', message: e.message }, status: :unprocessable_entity
  end
end
