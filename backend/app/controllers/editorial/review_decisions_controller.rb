module Editorial
  class ReviewDecisionsController < BaseController
    before_action :set_context

    def new
      @review_decision = @revision.review_decisions.new
    end

    def create
      Editorial::RecordDecision.call(
        revision: @revision,
        reviewer: current_user,
        review_kind: review_params[:review_kind],
        decision: review_params[:decision],
        notes: review_params[:notes],
        request_id: request.request_id
      )
      redirect_to editorial_content_item_content_revision_path(@content_item, @revision),
        notice: "Review decision recorded in the audit history."
    end

    private

    def set_context
      @content_item = ContentItem.find(params[:content_item_id])
      @revision = @content_item.revisions.find(params[:content_revision_id])
      raise Editorial::Error, "Reviewer role required." unless @revision.content_item.required_review_kinds.any? { |kind| current_user.can_review?(kind) }
    end

    def review_params
      params.require(:review_decision).permit(:review_kind, :decision, :notes)
    end
  end
end
