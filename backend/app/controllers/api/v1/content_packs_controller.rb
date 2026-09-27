module Api
  module V1
    class ContentPacksController < ActionController::API
      include PublicApiCors

      def latest
        render_pack(ContentPack.release_order.first)
      end

      def show
        render_pack(ContentPack.status_published.find_by(public_id: params[:public_id]))
      end

      private

      def render_pack(pack)
        return render json: { error: "content_pack_not_found" }, status: :not_found unless pack

        return unless stale?(etag: pack.checksum, last_modified: pack.published_at, public: true)

        response.headers["X-Content-Checksum"] = pack.checksum
        response.headers["Cache-Control"] = "public, max-age=300, stale-if-error=86400"
        render json: {
          id: pack.public_id,
          version: pack.pack_version,
          checksum: pack.checksum,
          published_at: pack.published_at,
          manifest: pack.manifest
        }
      end
    end
  end
end
