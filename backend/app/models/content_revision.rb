class ContentRevision < ApplicationRecord
  enum :status, { draft: 0, in_review: 1, approved: 2, published: 3, superseded: 4 },
    prefix: true

  belongs_to :content_item, inverse_of: :revisions
  belongs_to :author, class_name: "User", inverse_of: :authored_revisions
  has_many :review_decisions, dependent: :restrict_with_error
  has_many :content_pack_entries, dependent: :restrict_with_error
  has_many :content_packs, through: :content_pack_entries

  before_validation :assign_number, on: :create
  before_validation :refresh_checksum

  validates :number, numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :content_item_id }
  validates :body, presence: true
  validates :checksum, presence: true, length: { is: 64 }
  validate :body_must_be_an_object
  validate :body_is_immutable_after_submission, on: :update

  def approved_for_publish?
    (status_approved? || status_published? || status_superseded?) &&
      required_approvals_complete?
  end

  def required_approvals_complete?
    decisions = review_decisions.index_by(&:review_kind)
    content_item.required_review_kinds.all? do |kind|
      decisions[kind]&.decision_approved?
    end
  end

  private

  def assign_number
    self.number ||= (content_item&.revisions&.maximum(:number) || 0) + 1
  end

  def refresh_checksum
    self.checksum = Digest::SHA256.hexdigest(ContentPacks::CanonicalJson.dump(body || {}))
  end

  def body_must_be_an_object
    errors.add(:body, "must be a JSON object") unless body.is_a?(Hash)
  end

  def body_is_immutable_after_submission
    return unless will_save_change_to_body?
    return if status_in_database == "draft"

    errors.add(:body, "cannot change after submission; create a new revision")
  end
end
