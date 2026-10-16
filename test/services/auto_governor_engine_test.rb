require "test_helper"

class AutoGovernorEngineTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @department = Department.new(
      name: "Machine Learning Platform",
      cost_center_code: "CP-201"
    )
    @warehouse = Warehouse.new(
      name: "Model-Training-Wh",
      size: "large",
      status: "throttled",
      credit_quota: 1000,
      credits_used: 1050,
      sla_target_at: 15.minutes.from_now,
      department: @department
    )
  end

  test "does not suspend warehouse before 15 minute SLA expires" do
    travel 10.minutes do
      assert_not @warehouse.sla_breached_now?
      assert_equal "throttled", @warehouse.status
    end
  end

  test "flags warehouse as breached after 15 minute SLA expires" do
    travel 16.minutes do
      assert @warehouse.sla_breached_now?
    end
  end
end
