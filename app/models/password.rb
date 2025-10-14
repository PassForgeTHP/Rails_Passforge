class Password < ApplicationRecord
  # Associations
  belongs_to :user # Automatically validates presence of user

  # Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :username, length: { maximum: 255 }, allow_blank: true
  validates :domain, length: { maximum: 255 }, allow_blank: true
  validates :notes, length: { maximum: 5000 }, allow_blank: true
  validates :password_encrypted, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_domain, ->(domain) { where(domain: domain) }
  scope :search_title, ->(query) { where("title ILIKE ?", "%#{query}%") }
  scope :search_username, ->(query) { where("username ILIKE ?", "%#{query}%") }
  scope :search_domain, ->(query) { where("domain ILIKE ?", "%#{query}%") }
end
