require "test_helper"
require "rake"
require "csv"

class ApplyReviewSheetTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    @editor = create_user(role: :editor)
    create_user(role: :language_reviewer, email: "language@local.test")
    create_user(role: :culture_reviewer, email: "culture@local.test")
    create_user(role: :publisher, email: "publisher@local.test")
    @items = %w[word.ok word.fix word.drop word.wait].to_h do |id|
      item, revision = create_draft(author: @editor, stable_id: id)
      revision.update!(body: { "content" => { "canonical_form" => id, "definition_mizo" => "Old", "glosses" => { "en" => "old" } } })
      submit(revision, @editor)
      [ id, item ]
    end
  end

  test "ok approves, fix applies the correction then approves, drop archives, blank waits" do
    sheet = Tempfile.new([ "sheet", ".csv" ])
    CSV.open(sheet.path, "w") do |csv|
      csv << %w[stable_id decision fixed_mizo_meaning fixed_english_meaning reviewer_note]
      csv << [ "word.ok", "ok", "", "", "" ]
      csv << [ "word.fix", "fix", "Thar", "new", "better wording" ]
      csv << [ "word.drop", "drop", "", "", "not Mizo" ]
      csv << [ "word.wait", "", "", "", "" ]
    end

    ENV["FILE"] = sheet.path
    assert_output(/approved: 1/) { Rake::Task["editorial:apply_review_sheet"].reenable || true; Rake::Task["editorial:apply_review_sheet"].invoke }
  ensure
    ENV.delete("FILE")
    assert @items["word.ok"].reload.status_approved?
    fixed = @items["word.fix"].reload
    assert fixed.status_approved?
    assert_equal "Thar", fixed.current_revision.body.dig("content", "definition_mizo")
    assert @items["word.drop"].reload.status_archived?
    assert @items["word.wait"].reload.status_in_review?
  end
end
