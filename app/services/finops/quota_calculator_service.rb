module Finops
  class QuotaCalculatorService
    def self.recalculate!(warehouse)
      new(warehouse).execute
    end

    def initialize(warehouse)
      @warehouse = warehouse
    end

    def execute
      total_used = @warehouse.credit_usage_logs.sum(:credits_spent)
      @warehouse.credits_used = total_used

      if @warehouse.quota_reached? && !@warehouse.suspended?
        if @warehouse.status != "throttled"
          Warehouses::StatusTransitionService.transition!(
            warehouse: @warehouse,
            to_status: "throttled",
            reason: "quota_100_breached"
          )
        end
      elsif @warehouse.warning_reached? && @warehouse.active?
        Warehouses::StatusTransitionService.transition!(
          warehouse: @warehouse,
          to_status: "warning",
          reason: "warning_threshold_reached"
        )
      end

      @warehouse.save!
      @warehouse
    end
  end
end
