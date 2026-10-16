class DashboardController < ApplicationController
  def index
    @warehouses = Warehouse.includes(:department).order(:name)
    @departments = Department.includes(:warehouses).order(:name)
    @recent_events = StatusEvent.includes(:warehouse, :triggered_by).order(created_at: :desc).limit(10)
    @active_alerts = CostAlert.includes(:warehouse).where(acknowledged: false).order(created_at: :desc)

    @total_quota = @warehouses.sum(:credit_quota)
    @total_used = @warehouses.sum(:credits_used)
    @throttled_count = @warehouses.where(status: "throttled").count
    @suspended_count = @warehouses.where(status: "suspended").count
  end
end
