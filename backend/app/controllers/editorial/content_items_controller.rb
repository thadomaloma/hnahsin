module Editorial
  class ContentItemsController < BaseController
    before_action -> { require_roles!(:editor) }, except: %i[index show open]
    before_action :set_content_item, only: %i[show edit update]

    def index
      scope = ContentItem.includes(:published_revision, :revisions).order(updated_at: :desc)
      scope = scope.where(status: params[:status]) if ContentItem.statuses.key?(params[:status])
      scope = scope.where(content_type: params[:content_type]) if ContentItem.content_types.key?(params[:content_type])
      if params[:q].present?
        like = "%#{ContentItem.sanitize_sql_like(params[:q].strip)}%"
        scope = scope.where("stable_id ILIKE :q OR title ILIKE :q", q: like)
      end
      words = Editorial::WordGames.catalog
      @game_counts = Editorial::WordGames::GAMES.keys.index_with { |game| words.count { |w| w.games.include?(game) } }
      @missing_picture_count = words.count { |w| w.complete? && !w.picture? }
      if Editorial::WordGames::GAMES.key?(params[:game]) || params[:picture] == "missing"
        matching = words.select do |w|
          (params[:game].blank? || w.games.include?(params[:game])) &&
            (params[:picture] != "missing" || (w.complete? && !w.picture?))
        end
        scope = scope.where(id: matching.map(&:item_id))
      end
      @status_options = ContentItem.statuses.keys
      @content_type_options = ContentItem.content_types.keys
      @pagy, @content_items = pagy(scope)
    end

    # The item a game shows under [stable_id]; ids the game builds itself
    # (a word's example sentence) or bundled prototype words fall back to a
    # search.
    def open
      stable_id = params[:stable_id].delete_prefix("sentence.word.")
      item = ContentItem.find_by(stable_id: stable_id)
      return redirect_to editorial_content_item_path(item) if item

      redirect_to editorial_content_items_path(q: stable_id.sub(/\A\w+\./, "")),
        alert: "No Studio item is called #{stable_id}; showing the closest matches."
    end

    def show
      @revisions = @content_item.revisions.includes(:author, :review_decisions)
    end

    def new
      type = ContentItem.content_types.key?(params[:content_type]) ? params[:content_type] : "word"
      @content_item = ContentItem.new(locale: "lus", content_type: type)
      @structured = Editorial::BodyForm.structured?(type) && params[:json].blank?
      @values = {}
    end

    def create
      @content_item = ContentItem.new(content_item_params)
      body = if Editorial::BodyForm.structured?(@content_item.content_type) && params[:fields].present?
        Editorial::BodyForm.build(content_type: @content_item.content_type, fields: form_fields,
          image: params.dig(:fields, :image), actor: current_user)
      else
        parse_body!
      end
      @content_item.title = default_title(body) if @content_item.title.blank?
      ContentItem.transaction do
        @content_item.save!
        Editorial::CreateRevision.call(
          content_item: @content_item,
          actor: current_user,
          body: body,
          request_id: request.request_id
        )
      end
      redirect_to editorial_content_item_path(@content_item), notice: "Content item created."
    end

    def edit; end

    def update
      @content_item.update!(params.require(:content_item).permit(:title))
      Audit::Record.call(
        actor: current_user,
        auditable: @content_item,
        action: "content_item.updated",
        request_id: request.request_id
      )
      redirect_to editorial_content_item_path(@content_item), notice: "Content details updated."
    end

    private

    def set_content_item
      @content_item = ContentItem.find(params[:id])
    end

    def content_item_params
      params.require(:content_item).permit(:stable_id, :content_type, :locale, :title)
    end

    def form_fields
      Editorial::FormFields.permit(params)
    end

    def default_title(body)
      values = Editorial::BodyForm.values(content_type: @content_item.content_type, body: body)
      values.values_at("word", "prompt_mizo", "text_mizo", "title", "game_id").compact.first.to_s.truncate(80)
    end

    def parse_body!
      JSON.parse(params.require(:content_item).fetch(:body_json))
    rescue JSON::ParserError
      raise Editorial::Error, "Revision body must be valid JSON."
    end
  end
end
