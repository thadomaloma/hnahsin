module Editorial
  class RecordDecision
    def self.call(revision:, reviewer:, review_kind:, decision:, notes: nil, request_id: nil)
      kind = review_kind.to_s
      outcome = decision.to_s
      raise Error, "revision is not awaiting review" unless revision.status_in_review?
      raise Error, "reviewer role is not authorized" unless reviewer&.active? && reviewer.can_review?(kind)
      raise Error, "authors cannot review their own revision" if revision.author_id == reviewer.id
      raise Error, "decision must be approved or rejected" unless %w[approved rejected].include?(outcome)
      if outcome == "approved" && revision.review_decisions.where.not(review_kind: kind)
          .where(reviewer: reviewer, decision: :approved).exists?
        raise Error, "language and culture approval require different reviewers"
      end

      ReviewDecision.transaction do
        review = revision.review_decisions.find_or_initialize_by(review_kind: kind)
        review.assign_attributes(
          reviewer: reviewer,
          decision: outcome,
          notes: notes,
          reviewed_at: Time.current
        )
        review.save!
        if outcome == "rejected"
          revision.update!(status: :superseded)
          revision.content_item.update!(status: :draft)
        elsif revision.required_approvals_complete?
          revision.update!(status: :approved, approved_at: Time.current)
          revision.content_item.update!(status: :approved)
        end
        Audit::Record.call(
          actor: reviewer,
          auditable: revision,
          action: "content_revision.#{outcome}",
          metadata: { review_kind: kind },
          request_id: request_id
        )
        review
      end
    end
  end
end
