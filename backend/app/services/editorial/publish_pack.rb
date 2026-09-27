module Editorial
  class PublishPack
    VERSION_FORMAT = /\A\d+\.\d+\.\d+\z/

    def self.call(pack_version:, actor:, content_item_ids: nil, revisions: nil, rollback_of: nil, request_id: nil)
      raise Error, "publisher role required" unless actor&.active? && actor.can_publish?
      raise Error, "pack version must use semantic versioning" unless VERSION_FORMAT.match?(pack_version.to_s)

      selected_revisions = if revisions
        revisions.to_a
      else
        approved = ContentItem.status_approved
        approved = approved.where(id: content_item_ids) unless content_item_ids.nil?
        approved_by_id = approved.includes(revisions: :review_decisions).index_by(&:id)
        previously_published = ContentItem.where.not(published_revision_id: nil)
          .where.not(status: :archived)
          .includes(published_revision: :review_decisions)
        selected = previously_published.index_by(&:id)
        approved_by_id.each { |id, item| selected[id] = item }
        selected.values.map do |item|
          approved_by_id.key?(item.id) ? item.current_revision : item.published_revision
        end.compact
      end
      selected_revisions.sort_by! { |revision| revision.content_item.stable_id }
      raise Error, "at least one approved item is required" if selected_revisions.empty?
      unless selected_revisions.all?(&:approved_for_publish?)
        raise Error, "every revision requires all approvals"
      end

      now = Time.current
      manifest = {
        schema_version: "1.0",
        language: "lus",
        pack_version: pack_version,
        generated_at: now.iso8601,
        items: selected_revisions.map do |revision|
          {
            stable_id: revision.content_item.stable_id,
            content_type: revision.content_item.content_type,
            revision: revision.number,
            checksum: revision.checksum,
            body: revision.body
          }
        end
      }
      checksum = Digest::SHA256.hexdigest(ContentPacks::CanonicalJson.dump(manifest))

      ContentPack.transaction do
        pack = ContentPack.create!(
          pack_version: pack_version,
          status: :building,
          manifest: manifest,
          checksum: checksum,
          created_by: actor,
          rollback_of: rollback_of
        )
        selected_revisions.each do |revision|
          item = revision.content_item
          pack.content_pack_entries.create!(content_revision: revision)
          next unless rollback_of || revision == item.current_revision

          previous = item.published_revision
          previous.update!(status: :superseded) if previous && previous != revision
          revision.update!(status: :published, published_at: now)
          item.update!(status: :published, published_revision: revision)
        end
        pack.update!(status: :published, published_at: now)
        Audit::Record.call(
          actor: actor,
          auditable: pack,
          action: rollback_of ? "content_pack.rolled_back" : "content_pack.published",
          metadata: { item_count: selected_revisions.length, checksum: checksum },
          request_id: request_id
        )
        pack
      end
    end
  end
end
