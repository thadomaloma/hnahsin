module Editorial
  class ContentPacksController < BaseController
    before_action -> { require_roles!(:publisher) }, only: %i[new create rollback]
    before_action :set_pack, only: %i[show rollback]

    def index
      @pagy, @content_packs = pagy(ContentPack.order(created_at: :desc))
    end

    def show
      scope = @content_pack.content_revisions
        .includes(:content_item)
        .joins(:content_item)
        .order("content_items.stable_id")
      @pagy, @revisions = pagy(scope)
    end

    def new
      @approved_items = ContentItem.status_approved.includes(:revisions).order(:stable_id)
    end

    def create
      pack = Editorial::PublishPack.call(
        pack_version: params.require(:content_pack).fetch(:pack_version),
        actor: current_user,
        content_item_ids: params.require(:content_pack).fetch(:content_item_ids, []),
        request_id: request.request_id
      )
      redirect_to editorial_content_pack_path(pack), notice: "Content pack published."
    end

    def rollback
      pack = Editorial::RollbackPack.call(
        source_pack: @content_pack,
        new_version: params.require(:content_pack).fetch(:pack_version),
        actor: current_user,
        request_id: request.request_id
      )
      redirect_to editorial_content_pack_path(pack), notice: "Rollback pack published as a new immutable release."
    end

    private

    def set_pack
      @content_pack = ContentPack.find(params[:id])
    end
  end
end
