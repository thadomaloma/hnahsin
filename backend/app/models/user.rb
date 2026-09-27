class User < ApplicationRecord
  has_secure_password

  enum :role, {
    admin: 0,
    editor: 1,
    language_reviewer: 2,
    culture_reviewer: 3,
    publisher: 4
  }, prefix: true

  has_many :authored_revisions,
    class_name: "ContentRevision",
    foreign_key: :author_id,
    inverse_of: :author,
    dependent: :restrict_with_error
  has_many :review_decisions,
    foreign_key: :reviewer_id,
    inverse_of: :reviewer,
    dependent: :restrict_with_error

  normalizes :email, with: ->(value) { value.strip.downcase }

  validates :email, presence: true, uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true

  scope :active, -> { where(active: true) }

  def can_edit?
    role_admin? || role_editor?
  end

  def can_publish?
    role_admin? || role_publisher?
  end

  def can_review?(kind)
    role_admin? ||
      (kind.to_s == "language" && role_language_reviewer?) ||
      (kind.to_s == "culture" && role_culture_reviewer?)
  end
end
