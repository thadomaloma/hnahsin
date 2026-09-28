require "csv"

namespace :editorial do
  desc "Fill in words published without a meaning from a filled-in sheet " \
       "(content/review/missing_meanings_*.csv). decision column: ok = use the draft_* columns; " \
       "fix = use the fixed_* columns, falling back to the draft for any left blank; drop = archive; " \
       "blank = leave as is. The app needs a Mizo meaning, an English meaning and an example, so " \
       "rows missing any of them are skipped. New revisions are written by IMPORT_EDITOR_EMAIL and " \
       "approved by REVIEWER_EMAIL (language) and CULTURE_REVIEWER_EMAIL (culture, when required)."
  task apply_meaning_sheet: :environment do
    file = ENV.fetch("FILE") { abort "Set FILE=content/review/<sheet>.csv" }
    path = File.expand_path(file, Rails.root.join(".."))
    abort "No such file: #{path}" unless File.exist?(path)

    editor = User.find_by!(email: ENV.fetch("IMPORT_EDITOR_EMAIL", "editor@local.test"))
    language = User.find_by!(email: ENV.fetch("REVIEWER_EMAIL", "language@local.test"))
    culture = User.find_by!(email: ENV.fetch("CULTURE_REVIEWER_EMAIL", "culture@local.test"))
    publisher = User.find_by!(email: ENV.fetch("PUBLISHER_EMAIL", "publisher@local.test"))
    counts = Hash.new(0)
    errors = []

    CSV.foreach(path, headers: true) do |row|
      decision = row["decision"].to_s.strip.downcase
      next counts["left as is"] += 1 if decision.empty?

      item = ContentItem.find_by(stable_id: row["stable_id"].to_s.strip)
      next errors << "#{row["stable_id"]}: not found" unless item

      begin
        case decision
        when "drop"
          Editorial::ArchiveItem.call(content_item: item, actor: publisher,
            reason: "Dropped in #{File.basename(path)}: #{row["reviewer_note"].presence || "no note"}")
          counts["dropped"] += 1
        when "ok", "fix"
          pick = ->(field) { (decision == "fix" && row["fixed_#{field}"].present? ? row["fixed_#{field}"] : row["draft_#{field}"]).to_s.strip }
          meaning = { mizo: pick.call("mizo_meaning"), english: pick.call("english_meaning"), example: pick.call("example") }
          missing = meaning.select { |_, value| value.empty? }.keys
          next errors << "#{item.stable_id}: needs #{missing.join(", ")}" if missing.any?

          revision = meaning_sheet_revision(item, editor, meaning, row["draft_emoji"].to_s.strip)
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
    puts "Publish a new content pack (editorial:publish_content_pack) to deliver the words."
  end

  def meaning_sheet_revision(item, editor, meaning, emoji)
    body = item.current_revision.body.deep_dup
    if body["word"].is_a?(String)
      body.merge!("meaning_mizo" => meaning[:mizo], "english_gloss" => meaning[:english], "example_mizo" => meaning[:example])
      body["emoji"] = emoji if body["emoji"].blank? && emoji.present?
    else
      content = (body["content"] ||= {})
      content["definition_mizo"] = meaning[:mizo]
      content["glosses"] = (content["glosses"] || {}).merge("en" => meaning[:english])
      content["example_mizo"] = meaning[:example]
      content["emoji"] = emoji if content["emoji"].blank? && emoji.present?
    end
    revision = Editorial::CreateRevision.call(content_item: item, actor: editor, body: body)
    Editorial::SubmitRevision.call(revision: revision, actor: editor)
    revision
  end
end
