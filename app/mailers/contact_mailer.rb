class ContactMailer < ApplicationMailer
  default to: "passforge1@gmail.com"

  def contact_email(subject, email, content)
    
    @email = email
    @subject = subject
    @content = content
    mail(from: email, subject: subject)
  end
end
