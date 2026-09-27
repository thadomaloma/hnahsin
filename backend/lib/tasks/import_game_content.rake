namespace :editorial do
  desc "Import the app's built-in game content into Editorial Studio so it can be edited: " \
       "per-game Mizo text (content/game_copy), Tawng Upa questions (content/tawng_upa), " \
       "the two app-only Sentence Builder sentences and the bundled Picture Match " \
       "illustrations (assets/illustrations). Everything is submitted for review; the app " \
       "keeps its identical built-in defaults until a reviewed pack is published. Safe to re-run."
  task import_game_content: :environment do
    editor = User.find_by!(email: ENV.fetch("IMPORT_EDITOR_EMAIL", "editor@local.test"))
    raise "#{editor.email} cannot edit" unless editor.can_edit?

    root = Rails.root.join("..")
    created = Hash.new(0)
    skipped = 0

    create_item = lambda do |stable_id:, content_type:, fields:|
      if ContentItem.exists?(stable_id: stable_id)
        skipped += 1
        next
      end
      body = Editorial::BodyForm.build(content_type: content_type, fields: fields)
      title = Editorial::BodyForm.values(content_type: content_type, body: body)
        .values_at("prompt_mizo", "text_mizo", "title", "game_id").compact.first.to_s.truncate(80)
      ContentItem.transaction do
        item = ContentItem.create!(stable_id: stable_id, content_type: content_type, locale: "lus",
          title: title.presence || stable_id)
        revision = Editorial::CreateRevision.call(content_item: item, actor: editor, body: body)
        Editorial::SubmitRevision.call(revision: revision, actor: editor)
      end
      created[content_type] += 1
    end

    copy = JSON.parse(File.read(root.join("content/game_copy/default_game_copy.json")))
    copy.fetch("games").each do |game_id, text|
      fields = text.merge("game_id" => game_id, "instructions" => Array(text["instructions"]).join("\n"))
      create_item.call(stable_id: "game.#{game_id}", content_type: "game_copy", fields: fields)
    end

    questions = JSON.parse(File.read(root.join("content/tawng_upa/default_questions.json")))
    questions.fetch("questions").each.with_index(1) do |question, index|
      create_item.call(stable_id: format("question.tawng-upa.%03d", index), content_type: "question",
        fields: question)
    end

    [
      [ "sentence.local.001", "Lehkhabu ka chhiar.", "I read a book." ],
      [ "sentence.local.002", "Tui thianghlim in rawh.", "Please drink clean water." ]
    ].each do |stable_id, text, english|
      create_item.call(stable_id: stable_id, content_type: "sentence",
        fields: { "text_mizo" => text, "english_support" => english, "difficulty" => 2 })
    end

    pictures = 0
    Dir[root.join("assets/illustrations/word.*.png")].sort.each do |path|
      key = File.basename(path, ".png").delete_prefix("word.")
      item = ContentItem.find_by(stable_id: "word.#{key}", content_type: "word") ||
        ContentItem.where(content_type: "word").where.not(status: :archived)
          .find { |candidate| candidate.current_revision&.body&.dig("content", "canonical_form").to_s.downcase == key }
      next unless item && !item.status_archived?

      revision = item.current_revision
      image = WordImage.store!(File.open(path, "rb"), uploaded_by: editor)
      target = revision.body["word"].is_a?(String) ? revision.body : revision.body["content"]
      next if target.is_a?(Hash) && target.dig("image", "checksum") == image.checksum_sha256

      body = revision.body.deep_dup
      (body["word"].is_a?(String) ? body : (body["content"] ||= {}))["image"] = image.reference
      new_revision = Editorial::CreateRevision.call(content_item: item, actor: editor, body: body)
      Editorial::SubmitRevision.call(revision: new_revision, actor: editor)
      pictures += 1
    end

    puts "Created: #{created.map { |type, count| "#{count} #{type}" }.join(", ").presence || "nothing new"}"
    puts "Pictures attached to words: #{pictures}"
    puts "Already imported (skipped): #{skipped}"
    puts "Review and approve them in Editorial Studio, then publish a content pack."
  end
end
