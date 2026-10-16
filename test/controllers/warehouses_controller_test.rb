require "test_helper"

class WarehousesControllerTest < ActionDispatch::IntegrationTest
  test "should get warehouses index" do
    get warehouses_url
    assert_response :success
    assert_select "h1", /Sanal Veri Ambarları/
  end
end
