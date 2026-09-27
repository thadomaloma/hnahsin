require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "dashboard and navigation render without the retired audio pipeline" do
    sign_in(create_user(role: :admin))

    get "/dashboard"

    assert_response :success
    assert_select "a", text: "Content"
    assert_select "a", text: "Releases"
    assert_no_match(/audio/i, response.body)
  end

  test "retired audio routes are gone" do
    get "/api/v1/audio_packs/latest"
    assert_response :not_found
  end

  private

  def sign_in(user)
    post "/session", params: { email: user.email, password: "correct-horse-battery-staple" }
    assert_response :redirect
  end
end
