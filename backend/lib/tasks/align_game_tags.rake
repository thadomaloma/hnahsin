namespace :editorial do
  desc "One-time (2026-09-27): every game now honours a word's game tags. Tawng Upa and " \
       "Crossword used to ignore tags (every word was eligible) and Thumal Kawp borrowed " \
       "picture_match, so this adds tawng_upa + crossword to every tagged word and " \
       "thumal_kawp to picture_match words — nothing disappears from a game. Tag-only " \
       "change: prior approvals are re-recorded (same precedent as apply_emoji_corrections)."
  task align_game_tags: :environment do
    changed = reapproved = left_in_review = 0
    ContentItem.where(content_type: "word").where.not(status: :archived).includes(:revisions).find_each do |item|
      revision = item.current_revision
      body = revision.body.deep_dup
      flat = body["word"].is_a?(String)
      modes = Array(flat ? body["game_modes"] : body.dig("learning", "game_modes"))
      next if modes.empty? # untagged words already play in every game

      wanted = modes | %w[tawng_upa crossword]
      wanted |= %w[thumal_kawp] if modes.include?("picture_match")
      next if wanted.sort == modes.sort

      flat ? body["game_modes"] = wanted : (body["learning"] ||= {})["game_modes"] = wanted
      body["updated_at"] = Time.current.iso8601 if body.key?("updated_at")
      previous = item.status
      approvals = revision.review_decisions.where(decision: :approved).pluck(:review_kind, :reviewer_id)
      new_revision = Editorial::CreateRevision.call(content_item: item, actor: revision.author, body: body)
      Editorial::SubmitRevision.call(revision: new_revision, actor: revision.author)
      changed += 1
      if previous.in?(%w[approved published]) && approvals.any?
        approvals.each do |kind, reviewer_id|
          Editorial::RecordDecision.call(revision: new_revision, reviewer: User.find(reviewer_id),
            review_kind: kind, decision: "approved",
            notes: "Re-approved after aligning game tags (every game now honours tags). " \
                   "Word, meaning, example and picture are unchanged.")
        end
        reapproved += 1
      else
        left_in_review += 1
      end
    end
    puts "Updated #{changed} words (re-approved #{reapproved}, left in review #{left_in_review})."
    puts "Publish a new content pack to deliver them."
  end
end
