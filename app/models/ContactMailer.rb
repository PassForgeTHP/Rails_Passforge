class ContactMailer 
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email, :subject, :content

  validates :email, presence: true, format: { with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/  }
  validates :subject, presence: true
  validates :content, presence: true