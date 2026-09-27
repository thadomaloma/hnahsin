namespace :editorial do
  desc "One-time backlog clear: approve every in_review content item that carries " \
       "no VERIFY flag, no culture-sensitive note, and needs only language review " \
       "(see content/pilot/CHANGELOG_TQ_RECONCILIATION_2026-09-16.md, Addendum 12). " \
       "Items flagged VERIFY, culture-sensitive, or requiring culture review by " \
       "content type are left untouched for a real reviewer. New content going " \
       "forward should be reviewed one item at a time in Editorial Studio, not " \
       "swept up by this task -- it is meant to be run once against the existing " \
       "backlog, not wired into the regular import/review flow."
  task bulk_approve_safe_backlog: :environment do
    reviewer_email = ENV.fetch("BULK_APPROVE_REVIEWER_EMAIL", "language_reviewer@local.test")
    reviewer = User.find_by(email: reviewer_email)
    unless reviewer
      abort "No user found for #{reviewer_email.inspect}. " \
            "Set BULK_APPROVE_REVIEWER_EMAIL=you@example.com and re-run."
    end
    unless reviewer.can_review?("language")
      abort "#{reviewer.email} (role: #{reviewer.role}) is not authorized to perform " \
            "language review. Use a user with role admin or language_reviewer."
    end

    approved = 0
    skipped_flagged = 0
    skipped_needs_culture = 0
    skipped_no_revision = 0
    errors = []

    ContentItem.status_in_review.find_each do |item|
      revision = item.current_revision

      if revision.nil? || !revision.status_in_review?
        skipped_no_revision += 1
        next
      end

      unless item.required_review_kinds == ["language"]
        skipped_needs_culture += 1
        next
      end

      notes = revision.body.dig("provenance", "notes").to_s
      if notes.match?(/VERIFY/) || notes.match?(/culture-sensitive/i)
        skipped_flagged += 1
        next
      end

      if revision.author_id == reviewer.id
        errors << "#{item.stable_id}: reviewer is also the author -- use a different " \
                  "BULK_APPROVE_REVIEWER_EMAIL for this item"
        next
      end

      begin
        Editorial::RecordDecision.call(
          revision: revision,
          reviewer: reviewer,
          review_kind: "language",
          decision: "approved",
          notes: "Bulk-approved in the 2026-09-19 safe-backlog clear: no VERIFY flag " \
                 "and no culture-sensitivity note on this revision. See " \
                 "content/pilot/CHANGELOG_TQ_RECONCILIATION_2026-09-16.md, Addendum 12."
        )
        approved += 1
      rescue Editorial::Error => e
        errors << "#{item.stable_id}: #{e.message}"
      end
    end

    puts "Reviewer: #{reviewer.email}"
    puts "Approved: #{approved}"
    puts "Skipped (VERIFY or culture-sensitive note): #{skipped_flagged}"
    puts "Skipped (needs culture review by content type): #{skipped_needs_culture}"
    puts "Skipped (no revision awaiting review): #{skipped_no_revision}" if skipped_no_revision.positive?
    if errors.any?
      puts "\nErrors / not approved (#{errors.size}):"
      errors.each { |e| puts "  - #{e}" }
    end
  end
end
