module Api
  module V1
    # Public, immutable picture bytes for published words. Content-addressed
    # by SHA-256, so the app verifies exactly what reviewers approved.
    class WordImagesController < ActionController::API
      include PublicApiCors

      def show
        image = WordImage.find_by(checksum_sha256: params[:checksum])
        return head :not_found unless image&.published?

        response.headers["Cache-Control"] = "public, max-age=31536000, immutable"
        response.headers["X-Content-Checksum"] = image.checksum_sha256
        send_data image.data, type: image.content_type, disposition: "inline"
      end
    end
  end
end
