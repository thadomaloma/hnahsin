require "test_helper"

class FlagReviewTest < ActiveSupport::TestCase
  setup do
    @editor = create_user(role: :editor)
    @language = create_user(role: :language_reviewer)
    @culture = create_user(role: :culture_reviewer)
    @admin = create_user(role: :admin)
  end

  def flagged(id, notes: "VERIFY spelling.", culture: false)
    item, revision = create_draft(author: @editor, stable_id: id)
    revision.update!(body: {
      "content" => { "canonical_form" => id.delete_prefix("word."), "definition_mizo" => "Hmanrua.",
                     "glosses" => { "en" => "water pot/jar" }, "example_mizo" => "A tha e." },
      "learning" => { "cultural_review_required" => culture },
      "provenance" => { "notes" => "Source: Kumtluang. #{notes}" }
    })
    submit(revision, @editor)
    item
  end

  test "dictionary glosses are compared like the sheet script" do
    assert_equal "ok", Editorial::FlagReview.compare("to weave (bamboo)", "weave")
    assert_equal "check", Editorial::FlagReview.compare("water pot/jar", "earthen water jar")
    assert_equal "fix", Editorial::FlagReview.compare("a species of wild bird", "hornbill")
  end

  test "queue groups flagged words by reason" do
    flagged("word.tuium", notes: "VERIFY compound spelling.")
    flagged("word.zawlpuan", notes: "VERIFY culture-sensitive textile.", culture: true)
    groups = Editorial::FlagReview.queue.to_h { |row| [ row.item.stable_id, row.group ] }
    assert_equal({ "word.tuium" => "spelling", "word.zawlpuan" => "culture" }, groups)
  end

  test "ok records the reviewer's approval and notes the dictionary check" do
    item = flagged("word.tuium")
    outcome = Editorial::FlagReview.decide(item: item, user: @language, decision: "ok", gloss: "water jar")
    assert_equal "Approved.", outcome.message
    assert item.reload.status_approved?
    assert_match "Dictionary: water jar (ok)", item.current_revision.review_decisions.first.notes
  end

  test "culture words wait for a second, culture reviewer" do
    item = flagged("word.zawlpuan", notes: "VERIFY culture-sensitive.", culture: true)
    outcome = Editorial::FlagReview.decide(item: item, user: @language, decision: "ok")
    assert_match "waiting for a culture reviewer", outcome.message
    Editorial::FlagReview.decide(item: item, user: @culture, decision: "ok")
    assert item.reload.status_approved?
  end

  test "fix by an admin creates a corrected revision that someone else must review" do
    item = flagged("word.tuium")
    Editorial::FlagReview.decide(item: item, user: @admin, decision: "fix", fixed_english: "water jar")
    revision = item.reload.current_revision
    assert_equal "water jar", revision.body.dig("content", "glosses", "en")
    assert revision.status_in_review?
    assert_raises(Editorial::Error) { Editorial::FlagReview.decide(item: item, user: @admin, decision: "ok") }
  end

  test "fix and drop by a reviewer send the word back to editors" do
    item = flagged("word.tuium")
    Editorial::FlagReview.decide(item: item, user: @language, decision: "fix", fixed_english: "water jar")
    assert item.reload.status_draft?
    assert_match "Suggested fix", ReviewDecision.last.notes

    other = flagged("word.bullut")
    Editorial::FlagReview.decide(item: other, user: @admin, decision: "drop")
    assert other.reload.status_archived?
  end
end
