require "csv"

namespace :editorial do
  desc "Import content/pilot/*.csv as draft content items and submit them for review"
  task import_pilot_content: :environment do
    editor_email = ENV.fetch("IMPORT_EDITOR_EMAIL", "editor@local.test")
    editor = User.find_by!(email: editor_email)
    raise "#{editor.email} cannot edit" unless editor.can_edit?

    pilot_root = Rails.root.join("..", "content", "pilot")
    now = Time.current
    created = 0
    skipped = 0

    import_row = lambda do |stable_id:, content_type:, title:, body:|
      if ContentItem.exists?(stable_id: stable_id)
        skipped += 1
        next
      end

      ContentItem.transaction do
        item = ContentItem.create!(
          stable_id: stable_id,
          content_type: content_type,
          locale: "lus",
          title: title
        )
        revision = Editorial::CreateRevision.call(content_item: item, actor: editor, body: body)
        Editorial::SubmitRevision.call(revision: revision, actor: editor)
      end
      created += 1
    end

    # pilot_candidates.csv was widened to the same full Content Schema V2
    # columns as the diaspora/Kumtluang packs on 2026-09-16 (backfilling
    # english_gloss/meaning_mizo/example_mizo/difficulty/game_modes/emoji
    # for the 32 words that already exist in lib/src/data.dart's
    # wordEntries; the other 68 are left blank with a "content backfill
    # pending" note pending original authoring + review), so it now goes
    # through the same full-schema importer as those below instead of its
    # own hand-written block.

    CSV.foreach(pilot_root.join("pilot_sentences.csv"), headers: true) do |row|
      next if row["sentence_id"].blank?

      body = {
        "schema_version" => "2.0",
        "id" => row["sentence_id"],
        "revision" => 1,
        "type" => "sentence",
        "language" => "lus",
        "status" => "draft",
        "content" => {
          "text_mizo" => row["text_mizo"],
          "english_support" => row["english_support"],
          "linked_candidate_ids" => row["linked_candidate_ids"].to_s.split("|")
        },
        "learning" => {
          "tq_level" => row["tq_level"],
          "age_floor" => 5,
          "age_ceiling" => nil,
          "skills" => ["sentence"],
          "categories" => [],
          "difficulty" => 1,
          "sensitive" => false,
          "cultural_review_required" => row["sentence_id"] == "sentence.039",
          "game_modes" => []
        },
        "variants" => [],
        "provenance" => {
          "source_type" => "author",
          "source_title" => "Thumal Quest Phase 0 pilot sentence pack",
          "source_locator" => "pilot_sentences.csv",
          "contributor_id" => "contributor.phase0",
          "machine_assisted" => true,
          "machine_service" => nil,
          "machine_checked_at" => nil,
          "notes" => row["notes"].presence
        },
        "rights" => {
          "license" => "project-owned-draft",
          "copyright_holder" => "Thumal Quest project",
          "consent_record_id" => nil,
          "commercial_use_allowed" => false,
          "derivatives_allowed" => true,
          "attribution" => nil,
          "expires_at" => nil
        },
        "reviews" => [],
        "created_at" => now.iso8601,
        "updated_at" => now.iso8601
      }

      import_row.call(
        stable_id: row["sentence_id"],
        content_type: "sentence",
        title: row["text_mizo"],
        body: body
      )
    end

    # Full-schema candidate packs (diaspora expansion + Kumtluang curriculum
    # extraction) already carry the Content Schema V2 columns directly
    # (english_gloss, meaning_mizo, example_mizo, difficulty, game_modes,
    # emoji), unlike the older 9-column pilot_candidates.csv above.
    import_full_schema_csv = lambda do |csv_path:, source_type:, source_title:, contributor_id:|
      next unless File.exist?(csv_path)

      CSV.foreach(csv_path, headers: true) do |row|
        next if row["candidate_id"].blank?

        notes = row["notes"].to_s
        difficulty = Integer(row["difficulty"], exception: false) || 1
        # Kumtluang rows separate multiple game_modes with ",", but the
        # diaspora/vartian packs use "|" (see DIASPORA_BATCH_README.md) --
        # split on either so a pipe-separated row doesn't land as one
        # unsplit string like "spelling|listen_pick".
        game_modes = row["game_modes"].to_s.split(/[,|]/).map(&:strip).reject(&:empty?)
        sensitive = notes.match?(/VERIFY|age-safe|sensitive/i)
        cultural_review_required =
          notes.match?(/culture-sensitive|cultural review mandatory|cultural\/source review/i) ||
          row["seed_category"] == "culture"

        body = {
          "schema_version" => "2.0",
          "id" => row["candidate_id"],
          "revision" => 1,
          "type" => "word",
          "language" => "lus",
          "status" => "draft",
          "content" => {
            "canonical_form" => row["canonical_form"],
            "normalized_search" => row["canonical_form"].to_s.downcase,
            "seed_category" => row["seed_category"],
            "definition_mizo" => row["meaning_mizo"],
            "glosses" => { "en" => row["english_gloss"] },
            "example_mizo" => row["example_mizo"],
            "emoji" => row["emoji"]
          },
          "learning" => {
            "tq_level" => row["tq_level"],
            "age_floor" => 5,
            "age_ceiling" => nil,
            "skills" => ["vocabulary"],
            "categories" => [row["seed_category"]].compact,
            "difficulty" => difficulty,
            "sensitive" => sensitive,
            "cultural_review_required" => cultural_review_required,
            "game_modes" => game_modes
          },
          "variants" => [],
          "provenance" => {
            "source_type" => source_type,
            "source_title" => source_title,
            "source_locator" => csv_path.to_s,
            "contributor_id" => contributor_id,
            "machine_assisted" => true,
            "machine_service" => "claude-agent-extraction",
            "machine_checked_at" => now.iso8601,
            "notes" => notes.presence
          },
          "rights" => {
            "license" => "project-owned-draft",
            "copyright_holder" => "Thumal Quest project",
            "consent_record_id" => nil,
            "commercial_use_allowed" => false,
            "derivatives_allowed" => true,
            "attribution" => nil,
            "expires_at" => nil
          },
          "reviews" => [],
          "created_at" => now.iso8601,
          "updated_at" => now.iso8601
        }

        import_row.call(
          stable_id: row["candidate_id"],
          content_type: "word",
          title: row["canonical_form"],
          body: body
        )
      end
    end

    import_full_schema_csv.call(
      csv_path: pilot_root.join("pilot_candidates.csv"),
      source_type: "author",
      source_title: "Thumal Quest Phase 0 candidate pack",
      contributor_id: "contributor.phase0"
    )

    import_full_schema_csv.call(
      csv_path: pilot_root.join("diaspora_expansion_candidates.csv"),
      source_type: "author",
      source_title: "Thumal Quest diaspora expansion batch",
      contributor_id: "contributor.diaspora_expansion"
    )

    import_full_schema_csv.call(
      csv_path: pilot_root.join("kumtluang", "kumtluang_vocab_master_deduped.csv"),
      source_type: "curriculum",
      source_title: "Kumtluang Class I-VII (SCERT Mizoram) — cross-referenced vocabulary extraction",
      contributor_id: "contributor.kumtluang_extraction"
    )

    import_full_schema_csv.call(
      csv_path: pilot_root.join("vartian_candidates.csv"),
      source_type: "curriculum",
      source_title: "Vartian (Mizo literacy primer) — vocabulary extraction",
      contributor_id: "contributor.vartian_extraction"
    )

    puts "Imported #{created} content items and submitted them for review (#{skipped} already existed)."
  end
end
