module Editorial
  # Signed-in preview of any uploaded picture (including unreviewed drafts).
  class WordImagesController < BaseController
    def show
      image = WordImage.find_by!(checksum_sha256: params[:checksum])
      response.headers["Cache-Control"] = "private, max-age=3600"
      send_data image.data, type: image.content_type, disposition: "inline"
    end
  end
end
