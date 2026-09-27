# The v1 delivery API is public, read-only and unauthenticated, so any origin
# (including the Flutter web build on another localhost port) may read it.
module PublicApiCors
  extend ActiveSupport::Concern

  included do
    after_action :allow_public_cross_origin_reads
  end

  private

  def allow_public_cross_origin_reads
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Expose-Headers"] = "ETag, X-Content-Checksum"
  end
end
