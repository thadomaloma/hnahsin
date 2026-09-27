namespace :editorial do
  desc "One-time (2026-09-27): Sentence Builder had almost no sentences above level 2. " \
       "Tag every complete, tagged word whose example sentence has 3–9 words (a comfortable " \
       "number of tiles on a phone) for sentence_builder. Tag-only change: prior approvals " \
       "are re-recorded; words awaiting review stay in review."
  task tag_sentence_builder: :environment do
    changed = reapproved = 0
    Editorial::WordGames.catalog.each do |words|
      next unless words.complete? && words.modes.any? && !words.modes.include?("sentence_builder")
      next unless words.example.split.size.between?(3, 9)

      item = ContentItem.find(words.item_id)
      revision = item.current_revision
      body = revision.body.deep_dup
      flat = body["word"].is_a?(String)
      modes = Array(flat ? body["game_modes"] : body.dig("learning", "game_modes")) + [ "sentence_builder" ]
      flat ? body["game_modes"] = modes : body["learning"]["game_modes"] = modes
      body["updated_at"] = Time.current.iso8601 if body.key?("updated_at")

      previous = item.status
      approvals = revision.review_decisions.where(decision: :approved).pluck(:review_kind, :reviewer_id)
      new_revision = Editorial::CreateRevision.call(content_item: item, actor: revision.author, body: body)
      Editorial::SubmitRevision.call(revision: new_revision, actor: revision.author)
      changed += 1
      next unless previous.in?(%w[approved published]) && approvals.any?

      approvals.each do |kind, reviewer_id|
        Editorial::RecordDecision.call(revision: new_revision, reviewer: User.find(reviewer_id),
          review_kind: kind, decision: "approved",
          notes: "Re-approved after adding the sentence_builder game tag. Word, meaning, " \
                 "example and picture are unchanged.")
      end
      reapproved += 1
    end
    puts "Tagged #{changed} words for Sentence Builder (re-approved #{reapproved}, #{changed - reapproved} still in review)."
  end
end
