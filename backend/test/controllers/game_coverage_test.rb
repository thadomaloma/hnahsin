require "test_helper"

class GameCoverageTest < ActionDispatch::IntegrationTest
  setup do
    @editor = create_user(role: :editor)
    reviewer = create_user(role: :language_reviewer)
    publisher = create_user(role: :publisher)
    item, revision = create_draft(author: @editor, stable_id: "word.sakei")
    revision.update!(body: {
      "word" => "Sakei", "meaning_mizo" => "Ramsa hlauhawm.", "english_gloss" => "tiger",
      "example_mizo" => "Sakei a tlan.", "emoji" => "🐅", "category" => "nungcha", "difficulty" => 2,
      "game_modes" => %w[spelling]
    })
    submit(revision, @editor)
    approve(revision, language_reviewer: reviewer)
    Editorial::PublishPack.call(pack_version: "9.0.0", actor: publisher, content_item_ids: [ item.id ])
    @item = item
    post "/session", params: { email: @editor.email, password: "correct-horse-battery-staple" }
  end

  test "coverage shows live counts per game and level" do
    get "/editorial/coverage"
    assert_response :success
    assert_select "table.coverage tr", text: /Spelling/ do
      assert_select "td", text: /\A1\b/
    end
  end

  test "game filter lists words a game can use and bulk add sends them for review" do
    get "/editorial/content_items", params: { game: "spelling" }
    assert_response :success
    assert_select "span.code", text: "word.sakei"
    get "/editorial/content_items", params: { game: "crossword" }
    assert_select "span.code", text: "word.sakei", count: 0

    post "/editorial/bulk_game_modes", params: { item_ids: [ @item.id ], game: "crossword", operation: "add" }
    assert_redirected_to "/editorial/content_items"
    revision = @item.reload.current_revision
    assert_equal %w[spelling crossword], revision.body["game_modes"]
    assert revision.status_in_review?
  end
end
