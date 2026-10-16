class CostAlert < ApplicationRecord
  belongs_to :warehouse
  belongs_to :acknowledged_by, class_name: "User", optional: true

  ALERT_TYPES = %w[warning_80 breach_100].freeze

  validates :alert_type, inclusion: { in: ALERT_TYPES }
end
