class Warehouse < ApplicationRecord
  belongs_to :department

  has_many :credit_usage_logs, dependent: :destroy
  has_many :status_events, dependent: :destroy
  has_many :cost_alerts, dependent: :destroy

  STATUSES = %w[active warning throttled suspended].freeze
  SIZES    = %w[x-small small medium large x-large].freeze

  # Valid transitions
  TRANSITIONS = {
    "active"    => %w[warning throttled suspended],
    "warning"   => %w[active throttled suspended],
    "throttled" => %w[active suspended],
    "suspended" => %w[active]
  }.freeze

  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :size,   inclusion: { in: SIZES }
  validates :credit_quota, numericality: { greater_than: 0 }
  validates :credits_used, numericality: { greater_than_or_equal_to: 0 }
  validates :warning_threshold_pct, numericality: {
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 99
  }

  scope :active_or_warning, -> { where(status: %w[active warning]) }
  scope :throttled,         -> { where(status: "throttled") }
  scope :suspended,         -> { where(status: "suspended") }

  # ------------------------------------------------------------------ helpers

  def usage_pct
    return 0 if credit_quota.zero?
    (credits_used.to_f / credit_quota * 100).round(1)
  end

  def quota_reached?    = credits_used >= credit_quota
  def warning_reached?  = usage_pct >= warning_threshold_pct
  def active?           = status == "active"
  def warning?          = status == "warning"
  def throttled?        = status == "throttled"
  def suspended?        = status == "suspended"

  # Returns true when throttled and the 15-minute SLA window has expired.
  def sla_breached_now?
    throttled? && sla_target_at.present? && Time.current >= sla_target_at
  end

  # SLA countdown in seconds; nil when not throttled.
  def sla_seconds_remaining
    return nil unless throttled? && sla_target_at.present?
    [sla_target_at - Time.current, 0].max.to_i
  end

  # Credits remaining before quota is exhausted.
  def credits_remaining = [credit_quota - credits_used, 0].max

  # Can this warehouse accept new usage logs?
  def accepts_usage? = !suspended?
end
