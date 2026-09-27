require "csv"

namespace :editorial do
  desc "Apply a filled-in review sheet (content/review/*.csv). decision column: " \
       "ok = approve as is; fix = apply fixed_mizo_meaning / fixed_english_meaning, then approve; " \
       "drop = archive (keep out of every pack); blank = leave in review. Approvals are recorded " \
       "by REVIEWER_EMAIL (language) and CULTURE_REVIEWER_EMAIL (culture, when required)."
  task apply_review_sheet: :environment do
    file = ENV.fetch("FILE") { abort "Set FILE=content/review/<sheet>.csv" }
    path = File.expand_path(file, Rails.root.join(".."))
    abort "No such file: #{path}" unless File.exist?(path)

    language = User.find_by!(email: ENV.fetch("REVIEWER_EMAIL", "language@local.test"))
    culture = User.find_by!(email: ENV.fetch("CULTURE_REVIEWER_EMAIL", "culture@local.test"))
    publisher = User.find_by!(email: ENV.fetch("PUBLISHER_EMAIL", "publisher@local.test"))
    counts = Hash.new(0)
    errors = []

    CSV.foreach(path, headers: true) do |row|
      decision = row["decision"].to_s.strip.downcase
      next counts["left in review"] += 1 if decision.empty?

      item = ContentItem.find_by(stable_id: row["stable_id"].to_s.strip)
      next errors << "#{row["stable_id"]}: not found" unless item

      begin
        case decision
        when "drop"
          Editorial::ArchiveItem.call(content_item: item, actor: publisher,
            reason: "Dropped in review sheet #{File.basename(path)}: #{row["reviewer_note"].presence || "no note"}")
          counts["dropped"] += 1
        when "ok", "fix"
          revision = item.current_revision
          if decision == "fix"
            revision = review_sheet_fix(item, revision, row)
            next errors << "#{item.stable_id}: 'fix' needs a fixed meaning column" unless revision
          end
          review_sheet_approve(revision, item, language, culture, File.basename(path), row["reviewer_note"])
          counts[decision == "fix" ? "fixed and approved" : "approved"] += 1
        else
          errors << "#{item.stable_id}: unknown decision '#{decision}' (use ok, fix or drop)"
        end
      rescue Editorial::Error => e
        errors << "#{item.stable_id}: #{e.message}"
      end
    end

    counts.each { |label, count| puts "#{label}: #{count}" }
    errors.each { |error| puts "  ! #{error}" }
    puts "Publish a new content pack (editorial:publish_content_pack) to deliver approved words."
  end

  def review_sheet_fix(item, revision, row)
    mizo = row["fixed_mizo_meaning"].to_s.strip
    english = row["fixed_english_meaning"].to_s.strip
    return nil if mizo.empty? && english.empty?

    body = revision.body.deep_dup
    if body["word"].is_a?(String)
      body["meaning_mizo"] = mizo if mizo.present?
      body["english_gloss"] = english if english.present?
    else
      content = (body["content"] ||= {})
      content["definition_mizo"] = mizo if mizo.present?
      content["glosses"] = (content["glosses"] || {}).merge("en" => english) if english.present?
    end
    fixed = Editorial::CreateRevision.call(content_item: item, actor: revision.author, body: body)
    Editorial::SubmitRevision.call(revision: fixed, actor: revision.author)
    fixed
  end

  def review_sheet_approve(revision, item, language, culture, sheet, note)
    notes = "Confirmed by the project owner in review sheet #{sheet}. #{note}".strip
    item.required_review_kinds.each do |kind|
      next if revision.review_decisions.exists?(review_kind: kind)

      Editorial::RecordDecision.call(revision: revision, reviewer: kind == "culture" ? culture : language,
        review_kind: kind, decision: "approved", notes: notes)
    end
  end
end
