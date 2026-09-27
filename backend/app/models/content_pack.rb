require "digest"

class ContentPack < ApplicationRecord
  enum :status, { building: 0, published: 1, withdrawn: 2 }, prefix: true

  belongs_to :created_by, class_name: "User"
  belongs_to :rollback_of, class_name: "ContentPack", optional: true
  has_many :content_pack_entries, dependent: :restrict_with_error
  has_many :content_revisions, through: :content_pack_entries

  before_validation :assign_public_id, on: :create

  validates :public_id, :pack_version, :checksum, presence: true
  validates :public_id, :pack_version, uniqueness: true
  validates :checksum, length: { is: 64 }
  validates :manifest, presence: true
  validate :checksum_matches_manifest
  validate :published_release_is_complete

  scope :release_order, -> { status_published.order(published_at: :desc) }

  def readonly?
    persisted_release = status_in_database.in?(%w[published withdrawn])
    persisted_release || super
  end

  private

  def assign_public_id
    self.public_id ||= SecureRandom.uuid
  end

  def checksum_matches_manifest
    return if checksum.blank? || manifest.blank?
    expected = Digest::SHA256.hexdigest(ContentPacks::CanonicalJson.dump(manifest))
    errors.add(:checksum, "does not match manifest") unless ActiveSupport::SecurityUtils.secure_compare(checksum, expected)
  end

  def published_release_is_complete
    return unless status_published?

    errors.add(:published_at, "is required") if published_at.blank?
    errors.add(:content_revisions, "must contain reviewed content") if content_revisions.empty?
    unless content_revisions.all?(&:approved_for_publish?)
      errors.add(:content_revisions, "must all have required approvals")
    end
  end
end
