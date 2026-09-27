module Editorial
  # Retires a content item (e.g. a duplicate word) from future packs without
  # deleting it: revisions, reviews and past packs stay intact for audit.
  class ArchiveItem
    def self.call(content_item:, actor:, reason:, request_id: nil)
      raise Error, "publisher role required" unless actor&.active? && actor.can_publish?
      raise Error, "an archive reason is required" if reason.blank?

      content_item.with_lock do
        next if content_item.status_archived?

        previous_status = content_item.status
        content_item.update!(status: :archived)
        Audit::Record.call(
          actor: actor,
          auditable: content_item,
          action: "content_item.archived",
          metadata: { previous_status: previous_status, reason: reason },
          request_id: request_id
        )
      end
      content_item
    end
  end
end
