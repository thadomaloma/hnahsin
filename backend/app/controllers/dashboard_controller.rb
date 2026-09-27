class DashboardController < ApplicationController
  def show
    @counts = {
      draft: ContentItem.status_draft.count,
      review: ContentItem.status_in_review.count,
      approved: ContentItem.status_approved.count,
      published: ContentItem.status_published.count
    }
    @review_queue = ContentRevision.status_in_review.includes(:content_item, :author).order(submitted_at: :asc).limit(8)
    @latest_pack = ContentPack.release_order.first
    @recent_events = AuditEvent.includes(:actor).order(occurred_at: :desc).limit(8)
  end
end
