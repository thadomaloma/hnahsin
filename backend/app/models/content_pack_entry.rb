class ContentPackEntry < ApplicationRecord
  belongs_to :content_pack
  belongs_to :content_revision

  validates :content_revision_id, uniqueness: { scope: :content_pack_id }
end
