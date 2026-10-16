class CreditUsageLog < ApplicationRecord
  belongs_to :warehouse

  validates :credits_spent, numericality: { greater_than: 0 }
  validates :executed_at, presence: true
end
