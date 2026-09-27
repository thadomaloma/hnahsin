# Loaded here too so the queue works even before a running server reloads
# config/initializers/pagy.rb.
require "pagy/extras/array"

module Editorial
  class FlagReviewsController < BaseController
    PER_PAGE = 20

    before_action :require_reviewer!

    def index
      rows = FlagReview.queue
      @group_counts = FlagReview::GROUPS.keys.index_with { |group| rows.count { |row| row.group == group } }
      @group = FlagReview::GROUPS.key?(params[:group]) ? params[:group] : @group_counts.find { |_, count| count.positive? }&.first
      rows = rows.select { |row| row.group == @group }
      @pagy, @rows = pagy_array(rows, limit: PER_PAGE)
    end

    def update
      item = ContentItem.find(params[:id])
      outcome = FlagReview.decide(
        item: item, user: current_user, decision: params[:decision].to_s,
        gloss: params[:dictionary_gloss], fixed_english: params[:fixed_english], fixed_mizo: params[:fixed_mizo],
        note: params[:note], request_id: request.request_id
      )
      redirect_to editorial_flag_reviews_path(group: params[:group], page: params[:page], anchor: "queue"),
        notice: "#{item.title}: #{outcome.message}"
    end

    private

    def require_reviewer!
      return if %w[language culture].any? { |kind| current_user.can_review?(kind) }

      redirect_to dashboard_path, alert: "Only reviewers can open the flagged-word review."
    end
  end
end
