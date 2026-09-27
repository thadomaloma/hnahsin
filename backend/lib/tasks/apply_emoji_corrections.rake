namespace :editorial do
  desc "Apply content/pilot/emoji_corrections_*.json: a new revision per word with the " \
       "corrected emoji (null removes it), resubmitted for review. Emoji is display-only, " \
       "so words that were already approved/published get their prior reviewers' approvals " \
       "re-recorded on the corrected revision (same precedent as " \
       "fix_pipe_separated_game_modes); words still awaiting review stay in_review."
  task apply_emoji_corrections: :environment do
    file = ENV.fetch("EMOJI_CORRECTIONS") do
      Dir[Rails.root.join("..", "content", "pilot", "emoji_corrections_*.json")].max
    end
    abort "No emoji corrections file found." unless file && File.exist?(file)

    corrections = JSON.parse(File.read(file)).fetch("corrections")
    changed = 0
    reapproved = 0
    left_in_review = 0
    unchanged = 0
    errors = []

    corrections.each do |stable_id, emoji|
      item = ContentItem.find_by(stable_id: stable_id)
      next errors << "#{stable_id}: not found" unless item
      next errors << "#{stable_id}: archived" if item.status_archived?

      revision = item.current_revision
      body = revision.body.deep_dup
      next errors << "#{stable_id}: not a Schema V2 word body" unless body["content"].is_a?(Hash)

      if body["content"]["emoji"].presence == emoji.presence
        unchanged += 1
        next
      end

      previous_status = item.status
      approvals = revision.review_decisions.where(decision: :approved)
        .pluck(:review_kind, :reviewer_id)
      body["content"]["emoji"] = emoji.presence
      body["updated_at"] = Time.current.iso8601

      begin
        new_revision = Editorial::CreateRevision.call(
          content_item: item, actor: revision.author, body: body
        )
        Editorial::SubmitRevision.call(revision: new_revision, actor: revision.author)
        changed += 1

        if previous_status.in?(%w[approved published]) && approvals.any?
          approvals.each do |kind, reviewer_id|
            Editorial::RecordDecision.call(
              revision: new_revision,
              reviewer: User.find(reviewer_id),
              review_kind: kind,
              decision: "approved",
              notes: "Re-approved after a display-only emoji correction " \
                     "(#{File.basename(file)}). Reviewed word, meaning and example " \
                     "text are unchanged from the prior approved revision."
            )
          end
          reapproved += 1
        else
          left_in_review += 1
        end
      rescue Editorial::Error => e
        errors << "#{stable_id}: #{e.message}"
      end
    end

    puts "Corrections file: #{File.basename(file)}"
    puts "Updated: #{changed} (re-approved #{reapproved}, left in_review #{left_in_review})"
    puts "Already correct: #{unchanged}"
    if errors.any?
      puts "\nErrors (#{errors.size}):"
      errors.each { |error| puts "  - #{error}" }
    end
    puts "Publish a new pack (editorial:publish_content_pack) to deliver the fixes."
  end
end
