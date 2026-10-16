require "test_helper"

class StatusTransitionServiceTest < ActiveSupport::TestCase
  setup do
    @department = Department.new(
      name: "BI Platform",
      cost_center_code: "CP-301"
    )
    @warehouse = Warehouse.new(
      name: "Reporting-Wh",
      size: "medium",
      status: "active",
      credit_quota: 1000,
      credits_used: 500,
      department: @department
    )
  end

  test "active transitions to warning, throttled and suspended are allowed" do
    allowed = Warehouse::TRANSITIONS["active"]
    assert_includes allowed, "warning"
    assert_includes allowed, "throttled"
    assert_includes allowed, "suspended"
  end

  test "suspended warehouse cannot transition directly to throttled or warning" do
    allowed = Warehouse::TRANSITIONS["suspended"]
    assert_equal ["active"], allowed
    assert_not_includes allowed, "throttled"
    assert_not_includes allowed, "warning"
  end
end
