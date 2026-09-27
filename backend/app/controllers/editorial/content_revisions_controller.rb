module Editorial
  class ContentRevisionsController < BaseController
    before_action :set_content_item
    before_action :set_revision, only: %i[show submit]
    before_action -> { require_roles!(:editor) }, only: %i[create submit]

    def show; end

    def create
      body = if params[:fields].present?
        Editorial::BodyForm.build(content_type: @content_item.content_type,
          fields: Editorial::FormFields.permit(params),
          base: @content_item.current_revision&.body,
          image: params.dig(:fields, :image), actor: current_user)
      else
        JSON.parse(params.require(:content_revision).fetch(:body_json))
      end
      revision = Editorial::CreateRevision.call(
        content_item: @content_item,
        actor: current_user,
        body: body,
        request_id: request.request_id
      )
      redirect_to editorial_content_item_content_revision_path(@content_item, revision),
        notice: "Draft revision created."
    rescue JSON::ParserError
      raise Editorial::Error, "Revision body must be valid JSON."
    end

    def submit
      Editorial::SubmitRevision.call(
        revision: @revision,
        actor: current_user,
        request_id: request.request_id
      )
      redirect_to editorial_content_item_content_revision_path(@content_item, @revision),
        notice: "Revision submitted for independent review."
    end

    private

    def set_content_item
      @content_item = ContentItem.find(params[:content_item_id])
    end

    def set_revision
      @revision = @content_item.revisions.find(params[:id])
    end
  end
end
