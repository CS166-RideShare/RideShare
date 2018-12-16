require 'test_helper'

class MainPagesControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "should got to front first" do
    get front_url
    assert_response :success
    assert_select "title", "RideShare"
  end





end
