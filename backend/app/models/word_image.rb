# A picture for Picture Match (and other picture games), stored in the
# database and addressed by its SHA-256 so a reviewed revision always points
# at exactly the bytes a reviewer saw.
class WordImage < ApplicationRecord
  MAX_BYTES = 512 * 1024
  SIGNATURES = {
    "image/png" => "\x89PNG\r\n\x1A\n".b,
    "image/jpeg" => "\xFF\xD8\xFF".b
  }.freeze

  belongs_to :uploaded_by, class_name: "User"

  validates :checksum_sha256, presence: true, uniqueness: true, format: { with: /\A[0-9a-f]{64}\z/ }
  validates :content_type, inclusion: { in: %w[image/png image/jpeg image/webp] }
  validates :byte_size, numericality: { greater_than: 0, less_than_or_equal_to: MAX_BYTES }

  # Stores an uploaded file (or returns the identical one already stored).
  def self.store!(upload, uploaded_by:)
    bytes = upload.read.to_s.b
    raise Editorial::Error, "Picture is empty." if bytes.empty?
    raise Editorial::Error, "Picture must be 512 KB or smaller." if bytes.bytesize > MAX_BYTES

    content_type = sniff(bytes)
    raise Editorial::Error, "Picture must be a PNG, JPEG or WebP image." unless content_type

    checksum = Digest::SHA256.hexdigest(bytes)
    find_by(checksum_sha256: checksum) ||
      create!(checksum_sha256: checksum, content_type: content_type, byte_size: bytes.bytesize,
        data: bytes, uploaded_by: uploaded_by)
  end

  def self.sniff(bytes)
    return "image/webp" if bytes.start_with?("RIFF".b) && bytes.byteslice(8, 4) == "WEBP".b

    SIGNATURES.find { |_, signature| bytes.start_with?(signature) }&.first
  end

  # Only pictures used by a published revision are public.
  def published?
    ContentRevision.status_published
      .where("body -> 'content' -> 'image' ->> 'checksum' = :c OR body -> 'image' ->> 'checksum' = :c",
        c: checksum_sha256)
      .exists?
  end

  def reference
    { "checksum" => checksum_sha256, "content_type" => content_type, "byte_size" => byte_size }
  end
end
