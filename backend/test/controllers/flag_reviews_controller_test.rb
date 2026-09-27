require "test_helper"

class FlagReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @editor = create_user(role: :editor)
    @reviewer = create_user(role: :language_reviewer)
    @item, revision = create_draft(author: @editor, stable_id: "word.tuium")
    revision.update!(body: { "content" => { "canonical_form" => "Tui um", "glosses" => { "en" => "water pot" } },
                             "provenance" => { "notes" => "VERIFY compound spelling." } })
    submit(revision, @editor)
  end

  test "reviewers see the queue and record a decision" do
    sign_in(@reviewer)
    get "/editorial/flag_reviews"
    assert_response :success
    assert_select ".flag-card h2", text: "Tui um"
    assert_select "input.dictionary-gloss[data-ours='water pot']"

    patch "/editorial/flag_reviews/#{@item.id}", params: { decision: "ok", dictionary_gloss: "water jar", group: "spelling" }
    assert_redirected_to %r{/editorial/flag_reviews}
    assert @item.reload.status_approved?
  end

  test "editors cannot open the reviewer queue" do
    sign_in(@editor)
    get "/editorial/flag_reviews"
    assert_redirected_to "/dashboard"
  end

  private

  def sign_in(user)
    post "/session", params: { email: user.email, password: "correct-horse-battery-staple" }
  end
end
