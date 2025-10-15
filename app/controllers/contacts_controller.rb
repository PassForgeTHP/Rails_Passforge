class ContactsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  respond_to :json
  def create
    
    email = params[:email]
    subject = params[:subject]
    content = params[:content]

    contact = ContactMail.new(email: email, subject: subject, content: content)

    if contact.valid? 
    ContactMailer.contact_email(contact).deliver_now
      render json: { status: 'sent' }, status: :ok
    else
      render json: { status: 'error', message: contact.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  rescue => e
    render json: { status: 'error', message: e.message }, status: :internal_server_error
  end
end
