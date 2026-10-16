module Finops
  class AutoGovernorEngine
    # Scans for warehouses in throttled status whose 15-minute SLA has expired,
    # and safely transitions them to suspended status while generating an audit trail.
    def self.run!
      new.call
    end

    def call
      suspended_warehouses = []

      Warehouse.throttled.find_each do |warehouse|
        if warehouse.sla_breached_now?
          suspend_warehouse(warehouse)
          suspended_warehouses << warehouse
        end
      end

      suspended_warehouses
    end

    def suspend_warehouse(warehouse, actor: nil)
      ActiveRecord::Base.transaction do
        warehouse.update!(
          status: "suspended",
          sla_target_at: nil
        )

        warehouse.status_events.create!(
          from_status: "throttled",
          to_status: "suspended",
          reason: "sla_breach_auto_suspend",
          triggered_by: actor
        )

        warehouse.cost_alerts.create!(
          alert_type: "breach_100",
          acknowledged: false
        )
      end
    end
  end
end
