class Department < ApplicationRecord
  belongs_to :owner, class_name: "User", optional: true
  has_many :warehouses, dependent: :destroy

  validates :name, presence: true
  validates :cost_center_code, presence: true,
                               uniqueness: { case_sensitive: false },
                               format: { with: /\ACP-\d{3,6}\z/,
                                         message: "CP-NNN ile başlamalı (örn: CP-001)" }

  def total_credits_used = warehouses.sum(:credits_used)
  def total_quota        = warehouses.sum(:credit_quota)

  def usage_percentage
    return 0 if total_quota.zero?
    (total_credits_used.to_f / total_quota * 100).round(1)
  end
end
