require 'test_helper'

class PageControllerTest < ActionDispatch::IntegrationTest
  test "should get show_settings" do
    get page_show_settings_url
    assert_response :success
  end

  test "should get update_settings" do
    get page_update_settings_url
    assert_response :success
  end

end
