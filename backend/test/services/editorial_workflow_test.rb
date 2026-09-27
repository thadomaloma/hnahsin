require "test_helper"

class EditorialWorkflowTest < ActiveSupport::TestCase
  setup do
    @editor = create_user(role: :editor)
    @language_reviewer = create_user(role: :language_reviewer)
    @culture_reviewer = create_user(role: :culture_reviewer)
    @publisher = create_user(role: :publisher)
  end

  test "author cannot approve their own revision" do
    admin_author = create_user(role: :admin)
    _item, revision = create_draft(author: admin_author)
    submit(revision, admin_author)

    error = assert_raises(Editorial::Error) do
      Editorial::RecordDecision.call(
        revision: revision,
        reviewer: admin_author,
        review_kind: :language,
        decision: :approved
      )
    end
    assert_match(/cannot review/, error.message)
  end

  test "review role must match the required decision" do
    _item, revision = create_draft(author: @editor)
    submit(revision, @editor)

    assert_raises(Editorial::Error) do
      Editorial::RecordDecision.call(
        revision: revision,
        reviewer: @culture_reviewer,
        review_kind: :language,
        decision: :approved
      )
    end
  end

  test "story needs independent language and culture approvals" do
    item, revision = create_draft(author: @editor, content_type: :story)
    submit(revision, @editor)
    Editorial::RecordDecision.call(
      revision: revision,
      reviewer: @language_reviewer,
      review_kind: :language,
      decision: :approved
    )

    assert revision.reload.status_in_review?
    assert item.reload.status_in_review?

    Editorial::RecordDecision.call(
      revision: revision,
      reviewer: @culture_reviewer,
      review_kind: :culture,
      decision: :approved
    )
    assert revision.reload.status_approved?
    assert item.reload.status_approved?
  end

  test "publisher cannot release an unreviewed revision" do
    _item, revision = create_draft(author: @editor)

    assert_raises(Editorial::Error) do
      Editorial::PublishPack.call(
        pack_version: "1.0.0",
        actor: @publisher,
        revisions: [revision]
      )
    end
    assert_equal 0, ContentPack.count
  end

  test "approved content creates a checksummed immutable pack" do
    item, revision = create_draft(author: @editor, stable_id: "word.chibai")
    submit(revision, @editor)
    approve(revision, language_reviewer: @language_reviewer)

    pack = Editorial::PublishPack.call(
      pack_version: "1.0.0",
      actor: @publisher,
      content_item_ids: [item.id]
    )

    assert pack.status_published?
    assert_equal 64, pack.checksum.length
    assert_equal "word.chibai", pack.manifest.fetch("items").first.fetch("stable_id")
    assert_raises(ActiveRecord::ReadOnlyRecord) { pack.update!(pack_version: "9.9.9") }
  end

  test "a published record cannot be created without reviewed entries" do
    pack = ContentPack.new(
      pack_version: "8.0.0",
      status: :published,
      manifest: { "items" => [] },
      checksum: Digest::SHA256.hexdigest(ContentPacks::CanonicalJson.dump({ "items" => [] })),
      created_by: @publisher,
      published_at: Time.current
    )

    assert_not pack.valid?
    assert_includes pack.errors[:content_revisions], "must contain reviewed content"
  end

  test "rollback republishes the exact reviewed revision as a new version" do
    item, revision = create_draft(author: @editor, stable_id: "word.inn")
    submit(revision, @editor)
    approve(revision, language_reviewer: @language_reviewer)
    first = Editorial::PublishPack.call(
      pack_version: "1.0.0", actor: @publisher, content_item_ids: [item.id]
    )

    second_revision = Editorial::CreateRevision.call(
      content_item: item,
      actor: @editor,
      body: { "mizo" => "In", "english" => "House" }
    )
    submit(second_revision, @editor)
    approve(second_revision, language_reviewer: @language_reviewer)
    Editorial::PublishPack.call(
      pack_version: "1.1.0", actor: @publisher, content_item_ids: [item.id]
    )

    rollback = Editorial::RollbackPack.call(
      source_pack: first,
      new_version: "1.1.1",
      actor: @publisher
    )
    assert_equal first, rollback.rollback_of
    assert_equal [revision.id], rollback.content_revisions.pluck(:id)
    assert_equal revision.id, item.reload.published_revision_id
  end

  test "new release carries forward unchanged published content" do
    first_item, first_revision = create_draft(author: @editor, stable_id: "word.pa")
    submit(first_revision, @editor)
    approve(first_revision, language_reviewer: @language_reviewer)
    Editorial::PublishPack.call(
      pack_version: "3.0.0", actor: @publisher, content_item_ids: [first_item.id]
    )
    Editorial::CreateRevision.call(
      content_item: first_item,
      actor: @editor,
      body: { "mizo" => "Pa", "english" => "Father (draft correction)" }
    )

    second_item, second_revision = create_draft(author: @editor, stable_id: "word.nu")
    submit(second_revision, @editor)
    approve(second_revision, language_reviewer: @language_reviewer)
    pack = Editorial::PublishPack.call(
      pack_version: "3.1.0", actor: @publisher, content_item_ids: [second_item.id]
    )

    assert_equal %w[word.nu word.pa], pack.manifest.fetch("items").pluck("stable_id")
    assert first_item.reload.status_draft?
    assert_equal first_revision.id, first_item.published_revision_id
  end

  test "archived duplicates are left out of the next release" do
    kept_item, kept_revision = create_draft(author: @editor, stable_id: "word.beram-2")
    duplicate_item, duplicate_revision = create_draft(author: @editor, stable_id: "word.beram")
    [ kept_revision, duplicate_revision ].each do |revision|
      submit(revision, @editor)
      approve(revision, language_reviewer: @language_reviewer)
    end
    Editorial::PublishPack.call(
      pack_version: "4.0.0", actor: @publisher, content_item_ids: [ kept_item.id, duplicate_item.id ]
    )

    Editorial::ArchiveItem.call(
      content_item: duplicate_item, actor: @publisher, reason: "duplicate of word.beram-2"
    )
    pack = Editorial::PublishPack.call(pack_version: "4.0.1", actor: @publisher)

    assert_equal %w[word.beram-2], pack.manifest.fetch("items").pluck("stable_id")
    assert duplicate_item.reload.status_archived?
    assert_equal "content_item.archived", AuditEvent.where(auditable: duplicate_item).last.action
  end

  test "only publishers can archive content" do
    item, = create_draft(author: @editor)

    assert_raises(Editorial::Error) do
      Editorial::ArchiveItem.call(content_item: item, actor: @editor, reason: "duplicate")
    end
    assert item.reload.status_draft?
  end

  test "audit events cannot be changed or deleted" do
    _item, revision = create_draft(author: @editor)
    event = AuditEvent.find_by!(auditable: revision, action: "content_revision.created")

    assert_raises(ActiveRecord::ReadOnlyRecord) { event.update!(action: "changed") }
    assert_raises(ActiveRecord::ReadOnlyRecord) { event.destroy }
    assert AuditEvent.exists?(event.id)
  end
end
