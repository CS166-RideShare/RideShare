require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "the truth" do
    assert true
  end

  test "should get new" do
    get signup_url
    assert_response :success
  end

  def setup
    @user = User.new(name:"fake", email:"fake@fake.com", password:"12345678", password_confirmation:"12345678", phone_number:"6177633765", emergency_contact:"6177633765")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

end
