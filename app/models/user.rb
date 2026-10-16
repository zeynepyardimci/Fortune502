class User < ApplicationRecord
  has_secure_password

  has_many :departments, foreign_key: :owner_id, dependent: :nullify
  has_many :status_events, foreign_key: :triggered_by_id, dependent: :nullify
  has_many :acknowledged_alerts, class_name: "CostAlert",
                                 foreign_key: :acknowledged_by_id, dependent: :nullify

  ROLES = %w[admin manager analyst].freeze

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true
  validates :role, inclusion: { in: ROLES }

  def admin?   = role == "admin"
  def manager? = role == "manager"
  def analyst? = role == "analyst"
end
