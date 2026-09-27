namespace :editorial do
  desc "One-time fix: diaspora/vartian pilot rows separate multiple game_modes " \
       "with '|', but import_pilot_content.rake only ever split on ',', so " \
       "those rows landed with a single pipe-joined string (e.g. " \
       "'spelling|listen_pick') instead of separate array entries -- silently " \
       "breaking per-game content filtering for those words. This creates a " \
       "corrected draft revision for every affected item and resubmits it for " \
       "review. For items that were already approved/published before this " \
       "fix, it also re-records the same reviewer's language approval on the " \
       "corrected revision -- the reviewed word/meaning content is " \
       "byte-identical, only the game_modes delimiter changes. Items still " \
       "awaiting their first real review are left in_review for a human " \
       "reviewer, same as before."
  task fix_pipe_separated_game_modes: :environment do
    split_modes = lambda do |raw|
      Array(raw).flat_map { |mode| mode.to_s.split(/[,|]/) }.map(&:strip).reject(&:empty?).uniq
    end

    fixed_draft = 0
    reapproved = 0
    left_in_review = 0
    errors = []

    ContentItem.find_each do |item|
      revision = item.current_revision
      next unless revision

      modes = revision.body.dig("learning", "game_modes")
      next unless modes.is_a?(Array) && modes.any? { |mode| mode.to_s.include?("|") }

      previous_status = item.status
      previous_reviewer_id = revision.review_decisions
        .where(review_kind: :language, decision: :approved)
        .pick(:reviewer_id)

      corrected_body = revision.body.deep_dup
      corrected_body["learning"]["game_modes"] = split_modes.call(modes)

      begin
        new_revision = Editorial::CreateRevision.call(
          content_item: item,
          actor: revision.author,
          body: corrected_body
        )
        Editorial::SubmitRevision.call(revision: new_revision, actor: revision.author)
        fixed_draft += 1

        if previous_status.in?(%w[approved published]) && previous_reviewer_id
          Editorial::RecordDecision.call(
            revision: new_revision,
            reviewer: User.find(previous_reviewer_id),
            review_kind: "language",
            decision: "approved",
            notes: "Re-approved after a mechanical game_modes delimiter fix " \
                   "(pipe-separated tags from the import bug now split " \
                   "correctly). Reviewed word/meaning content is unchanged " \
                   "from the prior approved revision."
          )
          reapproved += 1
        else
          left_in_review += 1
        end
      rescue Editorial::Error => e
        errors << "#{item.stable_id}: #{e.message}"
      end
    end

    puts "Fixed (new draft created + resubmitted): #{fixed_draft}"
    puts "Re-approved (previously approved/published, content unchanged): #{reapproved}"
    puts "Left in_review for a human reviewer: #{left_in_review}"
    next unless errors.any?

    puts "\nErrors (#{errors.size}):"
    errors.each { |error| puts "  - #{error}" }
  end
end
