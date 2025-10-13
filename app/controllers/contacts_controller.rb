class ContactsController < ApplicationController
  respond_to :json
  def create
    email = params[:email]
    subject = params[:subject]
    content = params[:content]

    ContactMailer.contact_email(subject, email, content).deliver_now

    render json: { status: 'sent' }, status: :ok
  rescue => e
    render json: { status: 'error', message: e.message }, status: :unprocessable_entity
  end
end
