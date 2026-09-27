module Editorial
  class CreateRevision
    def self.call(content_item:, actor:, body:, request_id: nil)
      raise Error, "editor role required" unless actor&.active? && actor.can_edit?

      ContentRevision.transaction do
        content_item.lock!
        content_item.current_revision&.update!(status: :superseded)
        revision = content_item.revisions.create!(author: actor, body: body, status: :draft)
        content_item.update!(status: :draft)
        Audit::Record.call(
          actor: actor,
          auditable: revision,
          action: "content_revision.created",
          metadata: { stable_id: content_item.stable_id, number: revision.number },
          request_id: request_id
        )
        revision
      end
    end
  end
end
