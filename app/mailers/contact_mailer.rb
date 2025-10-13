class ContactMailer < ApplicationMailer
  default to: "passforge1@gmail.com"

  def contact_email(name, email, content)
    @name = name
    @email = email
    @content = content
    mail(from: email, subject: "Contact Form Message")
  end
end
