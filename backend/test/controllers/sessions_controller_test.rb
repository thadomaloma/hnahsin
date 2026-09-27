require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user(role: :editor, email: "editor@example.test")
  end

  test "active editorial user can sign in and sign out" do
    post "/session", params: {
      email: @user.email,
      password: "correct-horse-battery-staple"
    }
    assert_redirected_to "/dashboard"

    follow_redirect!
    assert_response :success
    assert_select "h1", text: /Editorial confidence/

    delete "/session"
    assert_redirected_to "/session/new"
  end

  test "inactive editorial user cannot sign in" do
    @user.update!(active: false)
    post "/session", params: {
      email: @user.email,
      password: "correct-horse-battery-staple"
    }

    assert_redirected_to "/session/new"
  end

  test "editorial pages require authentication" do
    get "/editorial/content_items"

    assert_redirected_to "/session/new"
  end
end
