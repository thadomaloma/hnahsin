require "test_helper"

class ContentItemTest < ActiveSupport::TestCase
  test "a plain word only requires language review" do
    editor = create_user(role: :editor)
    item = ContentItem.create!(stable_id: "word.zawlbuk", title: "Zawlbuk", content_type: :word, locale: "lus")
    Editorial::CreateRevision.call(
      content_item: item, actor: editor,
      body: { "content" => { "canonical_form" => "zawlbuk" }, "learning" => { "cultural_review_required" => false } }
    )

    assert_equal ["language"], item.reload.required_review_kinds
  end

  test "a word flagged cultural_review_required also requires culture review" do
    editor = create_user(role: :editor)
    item = ContentItem.create!(stable_id: "word.ralluaih", title: "Ral lu aih", content_type: :word, locale: "lus")
    Editorial::CreateRevision.call(
      content_item: item, actor: editor,
      body: {
        "content" => { "canonical_form" => "ral lu aih" },
        "learning" => { "cultural_review_required" => true },
        "provenance" => { "notes" => "VERIFY culture-sensitive: historical headhunting/war-trophy celebration custom." }
      }
    )

    assert_equal %w[language culture], item.reload.required_review_kinds
  end

  test "a culture-sensitive word cannot reach approved with only a language review" do
    editor = create_user(role: :editor)
    language_reviewer = create_user(role: :language_reviewer)
    item = ContentItem.create!(stable_id: "word.tapchepsut", title: "Tap chep sut", content_type: :word, locale: "lus")
    revision = Editorial::CreateRevision.call(
      content_item: item, actor: editor,
      body: { "content" => { "canonical_form" => "tap chep sut" }, "learning" => { "cultural_review_required" => true } }
    )
    submit(revision, editor)

    Editorial::RecordDecision.call(
      revision: revision, reviewer: language_reviewer, review_kind: :language,
      decision: :approved, notes: "Spelling and gloss confirmed."
    )

    refute revision.reload.status_approved?, "revision should not be approved without the required culture review"
    assert item.reload.status_in_review?, "content item should remain in_review pending culture sign-off"
  end
end
