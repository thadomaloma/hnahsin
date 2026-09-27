class ContentItem < ApplicationRecord
  attr_readonly :stable_id, :content_type, :locale

  CONTENT_TYPES = %w[word sentence story culture_card seasonal_trail question game_copy].freeze
  REVIEW_REQUIREMENTS = {
    "word" => %w[language],
    "sentence" => %w[language],
    "story" => %w[language culture],
    "culture_card" => %w[language culture],
    "seasonal_trail" => %w[language culture],
    "question" => %w[language],
    "game_copy" => %w[language]
  }.freeze

  enum :content_type, CONTENT_TYPES.each_with_index.to_h
  enum :status, { draft: 0, in_review: 1, approved: 2, published: 3, archived: 4 },
    prefix: true

  has_many :revisions, -> { order(number: :desc) },
    class_name: "ContentRevision",
    dependent: :restrict_with_error,
    inverse_of: :content_item
  belongs_to :published_revision, class_name: "ContentRevision", optional: true

  validates :stable_id, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9]+(?:[._-][a-z0-9]+)*\z/ }
  validates :title, presence: true
  validates :locale, inclusion: { in: %w[lus] }
  validate :published_revision_belongs_to_item

  def current_revision
    revisions.first
  end

  def required_review_kinds
    base = REVIEW_REQUIREMENTS.fetch(content_type)
    return base unless cultural_review_flagged?

    (base + ["culture"]).uniq
  end

  # Content-type review requirements (REVIEW_REQUIREMENTS) only cover the
  # *default* case for each type -- a plain "word" is assumed
  # language-only. That default is wrong for a specific word the import
  # pipeline flagged as touching sensitive cultural material (see
  # `import_pilot_content.rake`'s `cultural_review_required` detection,
  # which sets `body["learning"]["cultural_review_required"]`): those
  # need a culture reviewer's sign-off too, regardless of content_type.
  # Added 2026-09-19 after finding the flag was being computed and stored
  # on every row but never actually consulted here, so a culture-sensitive
  # word (e.g. the "ral lu aih" headhunting reference) could reach
  # `approved` -- and therefore become publishable -- with only a
  # language reviewer's sign-off and no culture reviewer involved at all.
  def cultural_review_flagged?
    !!current_revision&.body&.dig("learning", "cultural_review_required")
  end

  private

  def published_revision_belongs_to_item
    return unless published_revision && published_revision.content_item_id != id

    errors.add(:published_revision, "must belong to this content item")
  end
end
