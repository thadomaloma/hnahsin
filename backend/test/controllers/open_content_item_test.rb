require "test_helper"

class OpenContentItemTest < ActionDispatch::IntegrationTest
  setup do
    @editor = create_user(role: :editor)
    @reviewer = create_user(role: :language_reviewer)
    @item, = create_draft(author: @editor, stable_id: "word.auh")
  end

  test "opens a Studio item by the stable id the game shows" do
    sign_in(@reviewer)
    get "/editorial/open/word.auh"
    assert_redirected_to "/editorial/content_items/#{@item.id}"

    get "/editorial/open/sentence.word.word.auh"
    assert_redirected_to "/editorial/content_items/#{@item.id}"
  end

  test "an id Studio doesn't have falls back to a search" do
    sign_in(@reviewer)
    get "/editorial/open/word.nula"
    assert_redirected_to "/editorial/content_items?q=nula"
  end

  test "signing in returns to the item that was asked for" do
    get "/editorial/open/word.auh"
    assert_redirected_to "/session/new"
    sign_in(@reviewer)
    assert_redirected_to "/editorial/open/word.auh"
  end

  test "a plain sign-in still lands on the dashboard" do
    sign_in(@reviewer)
    assert_redirected_to "/dashboard"
  end

  private

  def sign_in(user)
    post "/session", params: { email: user.email, password: "correct-horse-battery-staple" }
  end
end
