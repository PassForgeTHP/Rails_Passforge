class ContactMailer < ApplicationMailer
  default to: "passforge1@gmail.com"

  def contact_email(contact_message)
    @contact = contact_message
    mail(from: @contact.email, subject: @contact.subject)
  end
end
