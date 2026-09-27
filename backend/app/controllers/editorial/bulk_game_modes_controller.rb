module Editorial
  class BulkGameModesController < BaseController
    before_action -> { require_roles!(:editor) }

    def create
      ids = Array(params[:item_ids]).map(&:to_i).uniq
      raise Error, "Select at least one word." if ids.empty?

      result = BulkGameModes.call(
        items: ContentItem.where(id: ids).includes(:revisions),
        game: params[:game].to_s, operation: params[:operation].to_s,
        actor: current_user, request_id: request.request_id
      )
      message = "#{result.changed} word(s) updated and sent for review."
      message += " Skipped #{result.skipped.size}: #{result.skipped.first(5).join(", ")}." if result.skipped.any?
      redirect_back fallback_location: editorial_content_items_path, notice: message
    end
  end
end
