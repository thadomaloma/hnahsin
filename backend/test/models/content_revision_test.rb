require "test_helper"

class ContentRevisionTest < ActiveSupport::TestCase
  test "checksum ignores JSON object key order" do
    editor = create_user(role: :editor)
    item = ContentItem.create!(stable_id: "word.nu", title: "Nu", content_type: :word, locale: "lus")
    first = Editorial::CreateRevision.call(
      content_item: item, actor: editor, body: { "mizo" => "Nu", "english" => "Mother" }
    )
    second = Editorial::CreateRevision.call(
      content_item: item, actor: editor, body: { "english" => "Mother", "mizo" => "Nu" }
    )

    assert_equal first.checksum, second.checksum
  end
end
