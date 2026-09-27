require "test_helper"

class EditorialFormsTest < ActionDispatch::IntegrationTest
  setup do
    @editor = create_user(role: :editor)
    sign_in(@editor)
  end

  test "editor creates a word with a picture from the form, then revises it" do
    get "/editorial/content_items/new?content_type=word"
    assert_response :success
    assert_select "input[type=file][name='fields[image]']"

    post "/editorial/content_items", params: {
      content_item: { stable_id: "word.favah", content_type: "word", locale: "lus", title: "" },
      fields: {
        word: "Favah", meaning_mizo: "Buh atna hmanrua.", english_gloss: "sickle",
        example_mizo: "Favah hmangin buh kan at.", emoji: "", category: "nunphung", difficulty: "2",
        game_modes: [ "picture_match", "spelling" ],
        image: fixture_file_upload("picture.png", "image/png")
      }
    }
    item = ContentItem.find_by!(stable_id: "word.favah")
    assert_redirected_to "/editorial/content_items/#{item.id}"
    assert_equal "Favah", item.title
    body = item.current_revision.body
    assert_equal WordImage.last.checksum_sha256, body.dig("content", "image", "checksum")
    assert_equal %w[picture_match spelling], body.dig("learning", "game_modes")

    get "/editorial/content_items/#{item.id}"
    assert_response :success
    assert_select "input[name='fields[meaning_mizo]']", 0
    assert_select "textarea[name='fields[meaning_mizo]']", text: "Buh atna hmanrua."

    post "/editorial/content_items/#{item.id}/content_revisions", params: {
      fields: {
        word: "Favah", meaning_mizo: "Buh atna chem kawm.", english_gloss: "sickle",
        example_mizo: "Favah hmangin buh kan at.", category: "nunphung", difficulty: "2"
      }
    }
    revision = item.reload.current_revision
    assert_equal 2, revision.number
    assert_equal "Buh atna chem kawm.", revision.body.dig("content", "definition_mizo")
    assert_equal body.dig("content", "image"), revision.body.dig("content", "image"), "picture is kept"

    get "/editorial/content_items/#{item.id}/content_revisions/#{revision.id}"
    assert_response :success
    assert_select ".learner-preview img"
    get "/editorial/word_images/#{WordImage.last.checksum_sha256}"
    assert_response :success
  end

  test "editor creates a Tawng Upa question and game text from forms" do
    post "/editorial/content_items", params: {
      content_item: { stable_id: "question.tawng-upa.100", content_type: "question", locale: "lus" },
      fields: { prompt_mizo: "“Hnial” tih awmzia eng nge?", options: [ "Thu sawi inpersan", "Hla sak", "Tlan chak", "Chaw ei" ],
                answer: "Thu sawi inpersan", explanation_mizo: "Hnial chu inpersan a ni.", difficulty: "1" }
    }
    assert_equal "question", ContentItem.find_by!(stable_id: "question.tawng-upa.100").content_type

    post "/editorial/content_items", params: {
      content_item: { stable_id: "game.picture_match", content_type: "game_copy", locale: "lus" },
      fields: { game_id: "picture_match", prompt: "He thlalak hming hi eng nge?" }
    }
    copy = ContentItem.find_by!(stable_id: "game.picture_match")
    assert_equal "He thlalak hming hi eng nge?", copy.current_revision.body["prompt"]
  end

  private

  def sign_in(user)
    post "/session", params: { email: user.email, password: "correct-horse-battery-staple" }
    assert_response :redirect
  end
end
