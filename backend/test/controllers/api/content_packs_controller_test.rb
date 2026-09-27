require "test_helper"

class Api::ContentPacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    editor = create_user(role: :editor)
    reviewer = create_user(role: :language_reviewer)
    publisher = create_user(role: :publisher)
    item, revision = create_draft(author: editor, stable_id: "word.thingpui")
    submit(revision, editor)
    approve(revision, language_reviewer: reviewer)
    @pack = Editorial::PublishPack.call(
      pack_version: "2.0.0", actor: publisher, content_item_ids: [item.id]
    )
  end

  test "latest returns only a published pack with integrity headers" do
    get "/api/v1/content_packs/latest"

    assert_response :success
    payload = response.parsed_body
    assert_equal @pack.public_id, payload.fetch("id")
    assert_equal @pack.checksum, payload.fetch("checksum")
    assert_equal @pack.checksum, response.headers.fetch("X-Content-Checksum")
    assert_match(/stale-if-error/, response.headers.fetch("Cache-Control"))
  end

  test "pack supports conditional requests" do
    get "/api/v1/content_packs/#{@pack.public_id}"
    etag = response.headers.fetch("ETag")
    get "/api/v1/content_packs/#{@pack.public_id}", headers: { "If-None-Match" => etag }

    assert_response :not_modified
  end

  test "public delivery responses can be read by the Flutter web build" do
    get "/api/v1/content_packs/latest"

    assert_equal "*", response.headers.fetch("Access-Control-Allow-Origin")
    assert_match(/ETag/, response.headers.fetch("Access-Control-Expose-Headers"))
  end

  test "unknown and non-published packs are not exposed" do
    get "/api/v1/content_packs/missing"

    assert_response :not_found
    assert_equal "content_pack_not_found", response.parsed_body.fetch("error")
  end
end
