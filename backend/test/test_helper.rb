ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)

  private

  def create_user(role:, email: nil)
    User.create!(
      email: email || "#{role}-#{SecureRandom.hex(4)}@example.test",
      password: "correct-horse-battery-staple",
      role: role
    )
  end

  def create_draft(author:, content_type: :word, stable_id: nil)
    item = ContentItem.create!(
      stable_id: stable_id || "#{content_type}.#{SecureRandom.hex(5)}",
      title: "Chibai",
      content_type: content_type,
      locale: "lus"
    )
    revision = Editorial::CreateRevision.call(
      content_item: item,
      actor: author,
      body: { "mizo" => "Chibai", "english" => "Hello" }
    )
    [item, revision]
  end

  def submit(revision, editor)
    Editorial::SubmitRevision.call(revision: revision, actor: editor)
  end

  def approve(revision, language_reviewer:, culture_reviewer: nil)
    Editorial::RecordDecision.call(
      revision: revision,
      reviewer: language_reviewer,
      review_kind: :language,
      decision: :approved,
      notes: "Natural Mizo confirmed."
    )
    return unless revision.content_item.required_review_kinds.include?("culture")

    Editorial::RecordDecision.call(
      revision: revision.reload,
      reviewer: culture_reviewer,
      review_kind: :culture,
      decision: :approved,
      notes: "Cultural context confirmed."
    )
  end

  def create_content_item(stable_id: nil, author:, language_reviewer:)
    item = ContentItem.create!(
      stable_id: stable_id || "word.#{SecureRandom.hex(5)}",
      title: "Chibai",
      content_type: :word,
      locale: "lus"
    )
    revision = Editorial::CreateRevision.call(
      content_item: item,
      actor: author,
      body: {
        "word" => "Chibai",
        "meaning_mizo" => "Inbiakna tawngkam",
        "english_gloss" => "Hello",
        "example_mizo" => "Chibai, i dam em?",
        "emoji" => "👋",
        "category" => "nunphung",
        "difficulty" => 1
      }
    )
    submit(revision, author)
    approve(revision, language_reviewer: language_reviewer)
    item.reload
  end
end
