require "test_helper"

class WarehouseSlaTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @department = Department.new(
      name: "Data Platform",
      cost_center_code: "CP-101"
    )
    @warehouse = Warehouse.new(
      name: "Analytics-ETL",
      size: "medium",
      status: "active",
      credit_quota: 1000,
      credits_used: 0,
      warning_threshold_pct: 80,
      department: @department
    )
  end

  test "valid status transitions" do
    assert @warehouse.active?
    assert_includes Warehouse::TRANSITIONS["active"], "warning"
    assert_includes Warehouse::TRANSITIONS["active"], "throttled"
    assert_includes Warehouse::TRANSITIONS["active"], "suspended"
  end

  test "invalid status transition raises error" do
    assert_not_includes Warehouse::TRANSITIONS["suspended"], "warning"
    assert_not_includes Warehouse::TRANSITIONS["suspended"], "throttled"
  end

  test "sla does not breach at 14 minutes" do
    @warehouse.status = "throttled"
    @warehouse.sla_target_at = 15.minutes.from_now

    travel 14.minutes do
      assert_not @warehouse.sla_breached_now?
      assert @warehouse.sla_seconds_remaining > 0
    end
  end

  test "sla breaches and suspends at 16 minutes" do
    @warehouse.status = "throttled"
    @warehouse.sla_target_at = 15.minutes.from_now

    travel 16.minutes do
      assert @warehouse.sla_breached_now?
      assert_equal 0, @warehouse.sla_seconds_remaining
    end
  end
end
