module Warehouses
  class StatusTransitionService
    class InvalidTransitionError < StandardError; end

    def self.transition!(warehouse:, to_status:, actor: nil, reason: nil)
      new(warehouse, to_status, actor, reason).execute
    end

    def initialize(warehouse, to_status, actor, reason)
      @warehouse = warehouse
      @to_status = to_status.to_s
      @actor = actor
      @reason = reason
    end

    def execute
      from_status = @warehouse.status

      unless valid_transition?(from_status, @to_status)
        raise InvalidTransitionError, "Cannot transition from #{from_status} to #{@to_status}"
      end

      ActiveRecord::Base.transaction do
        updates = { status: @to_status }

        if @to_status == "throttled"
          updates[:sla_target_at] = 15.minutes.from_now
        elsif @to_status == "active" || @to_status == "suspended"
          updates[:sla_target_at] = nil
        end

        @warehouse.update!(updates)

        @warehouse.status_events.create!(
          from_status: from_status,
          to_status: @to_status,
          reason: @reason || "manual_transition",
          triggered_by: @actor
        )
      end

      @warehouse
    end

    private

    def valid_transition?(from, to)
      allowed = Warehouse::TRANSITIONS[from]
      allowed && allowed.include?(to)
    end
  end
end
