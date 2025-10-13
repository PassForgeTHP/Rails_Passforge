class ContactMailer < ApplicationMailer
  default to: "passforge1@gmail.com"

  def contact_email(subject, email, content)
    
    @email = email
    @subject = subject
    @email = email
    @content = content
    mail(from: email, subject: "Contact Form Message")
  end
end
