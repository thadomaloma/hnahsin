module Editorial
  class SubmitRevision
    def self.call(revision:, actor:, request_id: nil)
      raise Error, "editor role required" unless actor&.active? && actor.can_edit?
      raise Error, "only draft revisions can be submitted" unless revision.status_draft?
      raise Error, "only the latest revision can be submitted" unless revision == revision.content_item.current_revision

      ContentRevision.transaction do
        revision.update!(status: :in_review, submitted_at: Time.current)
        revision.content_item.update!(status: :in_review)
        Audit::Record.call(
          actor: actor,
          auditable: revision,
          action: "content_revision.submitted",
          request_id: request_id
        )
        revision
      end
    end
  end
end
