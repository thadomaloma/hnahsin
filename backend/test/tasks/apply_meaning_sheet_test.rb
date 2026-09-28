require "test_helper"
require "rake"
require "csv"

class ApplyMeaningSheetTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    @editor = create_user(role: :editor, email: "editor@local.test")
    @language = create_user(role: :language_reviewer, email: "language@local.test")
    create_user(role: :culture_reviewer, email: "culture@local.test")
    @publisher = create_user(role: :publisher, email: "publisher@local.test")
    # Published seed words with no meaning, as the Phase 0 import left them.
    @items = %w[word.ok word.fix word.short word.drop word.wait].to_h do |id|
      item, revision = create_draft(author: @editor, stable_id: id)
      revision.update!(body: { "content" => { "canonical_form" => id.delete_prefix("word.") } })
      submit(revision, @editor)
      approve(revision, language_reviewer: @language)
      [ id, item ]
    end
    Editorial::PublishPack.call(pack_version: "1.0.0", actor: @publisher)
  end

  test "fills in meanings from drafts or fixes, then approves them for the next pack" do
    sheet = Tempfile.new([ "sheet", ".csv" ])
    CSV.open(sheet.path, "w") do |csv|
      csv << %w[stable_id draft_english_meaning draft_mizo_meaning draft_example draft_emoji decision
                fixed_english_meaning fixed_mizo_meaning fixed_example reviewer_note]
      csv << [ "word.ok", "star", "Zanah van-a eng.", "Arsi kan en.", "⭐", "ok", "", "", "", "" ]
      csv << [ "word.fix", "potato", "", "", "", "fix", "", "Bal ang chi thei.", "Alu kan ei.", "" ]
      csv << [ "word.short", "tea", "", "", "", "ok", "", "", "", "" ]
      csv << [ "word.drop", "", "", "", "", "drop", "", "", "", "duplicate" ]
      csv << [ "word.wait", "", "", "", "", "", "", "", "", "" ]
    end

    ENV["FILE"] = sheet.path
    task = Rake::Task["editorial:apply_meaning_sheet"]
    task.reenable
    assert_output(/approved: 1.*fixed and approved: 1.*word.short: needs mizo, example/m) { task.invoke }
  ensure
    ENV.delete("FILE")
    ok = @items["word.ok"].reload
    assert ok.status_approved?
    assert_equal({ "canonical_form" => "ok", "definition_mizo" => "Zanah van-a eng.", "glosses" => { "en" => "star" },
                   "example_mizo" => "Arsi kan en.", "emoji" => "⭐" }, ok.current_revision.body["content"])
    fixed = @items["word.fix"].reload
    assert fixed.status_approved?
    assert_equal "potato", fixed.current_revision.body.dig("content", "glosses", "en")
    assert_equal "Alu kan ei.", fixed.current_revision.body.dig("content", "example_mizo")
    assert_nil @items["word.short"].reload.current_revision.body.dig("content", "definition_mizo")
    assert @items["word.drop"].reload.status_archived?
    assert_equal 1, @items["word.wait"].reload.revisions.count
  end
end
