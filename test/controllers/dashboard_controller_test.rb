require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get root and display buzul brand" do
    get root_url
    assert_response :success
    assert_select "header.navbar", /Buzul/
    assert_select "main.container"
  end
end
