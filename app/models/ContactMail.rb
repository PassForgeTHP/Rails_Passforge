class ContactMail 
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email, :subject, :content

  validates :email, presence: true, format: { with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/  }
  validates :subject, presence: true, length: { minimum: 3, maximum: 100 , too_short: "the subject must be at least %{count} characters long.", too_long: "The subject must be at most %{count} characters long." }
  validates :content, presence: true, length: { minimum: 10, maximum: 1000 , too_short: "the content must be at least %{count} characters long.", too_long: "The content must be at most %{count} characters long." }


end