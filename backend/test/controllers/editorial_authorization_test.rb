require "test_helper"

class EditorialAuthorizationTest < ActionDispatch::IntegrationTest
  test "reviewer cannot open content creation" do
    reviewer = create_user(role: :language_reviewer)
    sign_in(reviewer)

    get "/editorial/content_items/new"
    assert_redirected_to "/dashboard"
  end

  test "editor can create a Mizo draft" do
    editor = create_user(role: :editor)
    sign_in(editor)

    post "/editorial/content_items", params: {
      content_item: {
        stable_id: "word.ei",
        title: "Ei",
        content_type: "word",
        locale: "lus",
        body_json: '{"mizo":"Ei","english":"Eat"}'
      }
    }

    item = ContentItem.find_by!(stable_id: "word.ei")
    assert_redirected_to "/editorial/content_items/#{item.id}"
    assert item.current_revision.status_draft?
  end

  private

  def sign_in(user)
    post "/session", params: {
      email: user.email,
      password: "correct-horse-battery-staple"
    }
    assert_response :redirect
  end
end
