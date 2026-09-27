class ReviewDecision < ApplicationRecord
  enum :review_kind, { language: 0, culture: 1 }, prefix: true
  enum :decision, { approved: 0, rejected: 1 }, prefix: true

  belongs_to :content_revision
  belongs_to :reviewer, class_name: "User", inverse_of: :review_decisions

  validates :review_kind, :decision, :reviewed_at, presence: true
  validates :review_kind, uniqueness: { scope: :content_revision_id }
  validates :notes, presence: true, if: :decision_rejected?
  validate :reviewer_is_active_and_authorized
  validate :reviewer_is_not_the_author
  validate :review_kind_is_required
  validate :reviewer_is_distinct_for_approval

  private

  def reviewer_is_active_and_authorized
    return if reviewer&.active? && reviewer.can_review?(review_kind)

    errors.add(:reviewer, "is not authorized for this review")
  end

  def reviewer_is_not_the_author
    return unless reviewer_id.present? && reviewer_id == content_revision&.author_id

    errors.add(:reviewer, "cannot review their own revision")
  end

  def review_kind_is_required
    return if content_revision&.content_item&.required_review_kinds&.include?(review_kind)

    errors.add(:review_kind, "is not required for this content type")
  end

  def reviewer_is_distinct_for_approval
    return unless decision_approved? && reviewer_id.present? && content_revision
    duplicate = content_revision.review_decisions
      .where(reviewer_id: reviewer_id, decision: :approved)
      .where.not(id: id)
      .exists?
    errors.add(:reviewer, "cannot provide both approvals") if duplicate
  end
end
