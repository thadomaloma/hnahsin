require "test_helper"

class BodyFormTest < ActiveSupport::TestCase
  test "word form updates a nested Schema V2 body and keeps unmanaged fields" do
    base = {
      "schema_version" => "2.0",
      "content" => { "canonical_form" => "Ṭhi", "definition_mizo" => "Old clue", "glosses" => { "en" => "beads" } },
      "learning" => { "difficulty" => 1, "tq_level" => "TQ1" },
      "provenance" => { "notes" => "keep me" }
    }
    body = Editorial::BodyForm.build(content_type: "word", base: base, fields: {
      "word" => "ṭhi", "meaning_mizo" => "Ṭhi chu ngawnga awrh chi hmanrua a ni.",
      "english_gloss" => "beads / necklace", "example_mizo" => "Ka nu ṭhi a mawi.",
      "emoji" => "📿", "category" => "nunphung", "difficulty" => "2", "game_modes" => %w[spelling bogus]
    })

    assert_equal "Ṭhi chu ngawnga awrh chi hmanrua a ni.", body.dig("content", "definition_mizo")
    assert_equal "nunphung", body["category"]
    assert_equal %w[spelling], body.dig("learning", "game_modes")
    assert_equal "TQ1", body.dig("learning", "tq_level")
    assert_equal "keep me", body.dig("provenance", "notes")
    assert_equal "ṭhi", Editorial::BodyForm.values(content_type: "word", body: body)["word"]
  end

  test "question form requires four distinct options containing the answer" do
    fields = {
      "prompt_mizo" => "“Zawlbuk” chu eng nge ni?", "explanation_mizo" => "Tlangvalte awmna.",
      "options" => [ "In", "Lo", "Tui", "Ram" ], "answer" => "In", "difficulty" => "3"
    }
    body = Editorial::BodyForm.build(content_type: "question", fields: fields)
    assert_equal "tawng_upa", body["game"]
    assert_equal 3, body["difficulty"]

    assert_raises(Editorial::Error) do
      Editorial::BodyForm.build(content_type: "question", fields: fields.merge("answer" => "Thing"))
    end
    assert_raises(Editorial::Error) do
      Editorial::BodyForm.build(content_type: "question", fields: fields.merge("options" => %w[In In Lo Tui]))
    end
  end

  test "game copy keeps only filled fields and splits instructions into steps" do
    body = Editorial::BodyForm.build(content_type: "game_copy", fields: {
      "game_id" => "picture_match", "prompt" => "He thlalak hming hi eng nge?",
      "instructions" => "Picture en rawh.\n\nHming thlang rawh.\n", "title" => ""
    })
    assert_equal [ "Picture en rawh.", "Hming thlang rawh." ], body["instructions"]
    assert_not body.key?("title")
    assert_raises(Editorial::Error) { Editorial::BodyForm.build(content_type: "game_copy", fields: { "game_id" => "nope" }) }
  end

  test "an uploaded picture is stored once and referenced by checksum" do
    editor = create_user(role: :editor)
    upload = -> { Rack::Test::UploadedFile.new(file_fixture("picture.png"), "image/png") }
    fields = { "word" => "Favah", "meaning_mizo" => "Buh atna.", "english_gloss" => "sickle",
               "example_mizo" => "Favah hmangin buh kan at.", "category" => "nunphung" }

    first = Editorial::BodyForm.build(content_type: "word", fields: fields, image: upload.call, actor: editor)
    second = Editorial::BodyForm.build(content_type: "word", fields: fields, image: upload.call, actor: editor)

    assert_equal 1, WordImage.count
    assert_equal "image/png", first.dig("content", "image", "content_type")
    assert_equal first.dig("content", "image"), second.dig("content", "image")
  end

  test "non-image uploads are rejected" do
    editor = create_user(role: :editor)
    upload = Rack::Test::UploadedFile.new(file_fixture("not_image.txt"), "image/png")
    assert_raises(Editorial::Error) { WordImage.store!(upload, uploaded_by: editor) }
  end
end
