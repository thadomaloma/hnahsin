require "test_helper"

class WordImagesApiTest < ActionDispatch::IntegrationTest
  test "pictures are public only once a published revision uses them" do
    editor = create_user(role: :editor)
    reviewer = create_user(role: :language_reviewer)
    publisher = create_user(role: :publisher)
    image = WordImage.store!(Rack::Test::UploadedFile.new(file_fixture("picture.png"), "image/png"),
      uploaded_by: editor)
    item, revision = create_draft(author: editor, stable_id: "word.favah")
    revision.update!(body: revision.body.merge("image" => image.reference))

    get "/api/v1/word_images/#{image.checksum_sha256}"
    assert_response :not_found

    submit(revision, editor)
    approve(revision, language_reviewer: reviewer)
    Editorial::PublishPack.call(pack_version: "5.0.0", actor: publisher, content_item_ids: [ item.id ])

    get "/api/v1/word_images/#{image.checksum_sha256}"
    assert_response :success
    assert_equal "image/png", response.media_type
    assert_equal image.checksum_sha256, Digest::SHA256.hexdigest(response.body)
    assert_equal "*", response.headers["Access-Control-Allow-Origin"]
  end
end
