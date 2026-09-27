module Editorial
  # The Studio queue for words the importer flagged (VERIFY / culture-sensitive).
  # A reviewer looks each one up in their own dictionary, notes the short
  # English meaning they found, and decides ok / fix / drop — always within the
  # maker-checker rules: nobody approves their own revision, language and
  # culture approvals come from different people, and fixes go back through
  # review.
  class FlagReview
    GROUPS = {
      "culture" => "Culture (needs a culture reviewer too)",
      "duplicate" => "Possible duplicate",
      "identity" => "Plant / animal identity uncertain",
      "spelling" => "Spelling / diacritics",
      "meaning" => "Meaning / sense",
      "other" => "Other"
    }.freeze
    DECISIONS = %w[ok fix drop].freeze
    STOP = %w[a an the to of or and be one something someone kind type e g].freeze

    Row = Data.define(:item, :revision, :group, :notes) do
      def values = BodyForm.values(content_type: "word", body: revision.body)
    end

    Outcome = Data.define(:message)

    def self.queue
      ContentItem.where(status: :in_review).includes(:revisions).filter_map do |item|
        revision = item.current_revision
        next unless revision&.status_in_review?

        notes = revision.body.dig("provenance", "notes").to_s
        next unless notes.match?(/VERIFY|culture-sensitive/i) || item.required_review_kinds.include?("culture")

        Row.new(item: item, revision: revision, group: group_for(notes, item),
          notes: notes.gsub(/\s+/, " ").sub(/\ASource: [^.]*\.\s*/, ""))
      end.sort_by { |row| [ GROUPS.keys.index(row.group), row.item.stable_id ] }
    end

    def self.group_for(notes, item)
      text = notes.downcase
      return "culture" if text.include?("culture-sensitive") || item.required_review_kinds.include?("culture")
      return "duplicate" if text.include?("duplicate")
      return "identity" if text.match?(/species|botanical|identity|uncertain/)
      return "spelling" if text.match?(/spelling|diacritic|compound|orthograph/)
      return "meaning" if text.match?(/sense|meaning|gloss|usage/)

      "other"
    end

    # ok / check / fix — same rules as scripts/compare_dictionary_glosses.py.
    def self.compare(ours, theirs)
      mine = alternatives(ours)
      reference = alternatives(theirs)
      return "check" if mine.empty? || reference.empty?

      best = mine.product(reference).map { |a, b| (a & b).size.to_f / (a | b).size }.max
      return "ok" if best >= 0.5

      best.positive? ? "check" : "fix"
    end

    def self.alternatives(text)
      text.to_s.downcase.gsub(/\(.*?\)/, " ").split(%r{[/,;]|\bor\b}).filter_map do |part|
        words = part.scan(/[a-z]+/).map { |word| word.length > 3 ? word.delete_suffix("s") : word } - STOP
        words.to_set if words.any?
      end
    end

    def self.decide(item:, user:, decision:, gloss: nil, fixed_english: nil, fixed_mizo: nil, note: nil, request_id: nil)
      raise Error, "Choose ok, fix or drop." unless DECISIONS.include?(decision)

      revision = item.current_revision
      raise Error, "This word is no longer waiting for review." unless revision&.status_in_review?

      english = BodyForm.values(content_type: "word", body: revision.body)["english_gloss"].to_s
      notes = [
        ("Dictionary: #{gloss.strip} (#{compare(english, gloss)})" if gloss.present?),
        note.presence
      ].compact.join(" · ")
      new(item, revision, user, notes, request_id).public_send(decision, fixed_english.to_s.strip, fixed_mizo.to_s.strip)
    end

    def initialize(item, revision, user, notes, request_id)
      @item = item
      @revision = revision
      @user = user
      @notes = notes
      @request_id = request_id
    end

    def ok(*)
      kinds = @item.required_review_kinds.select { |kind| @user.can_review?(kind) }
      kinds.reject! { |kind| @revision.review_decisions.exists?(review_kind: kind, decision: :approved) }
      raise Error, "Your role cannot review this word." if kinds.empty?

      # One person may give only one of the language/culture approvals.
      kind = kinds.first
      RecordDecision.call(revision: @revision, reviewer: @user, review_kind: kind, decision: "approved",
        notes: @notes.presence, request_id: @request_id)
      pending = @item.reload.required_review_kinds - @revision.reload.review_decisions.where(decision: :approved).pluck(:review_kind)
      Outcome.new(pending.empty? ? "Approved." : "#{kind.humanize} approved; waiting for a #{pending.first} reviewer.")
    end

    def fix(english, mizo)
      raise Error, "Write the corrected English or Mizo meaning." if english.empty? && mizo.empty?

      unless @user.can_edit?
        reject("Suggested fix — English: #{english.presence || "(unchanged)"}; Mizo: #{mizo.presence || "(unchanged)"}")
        return Outcome.new("Sent back to editors with your suggested fix.")
      end

      body = @revision.body.deep_dup
      if body["word"].is_a?(String)
        body["english_gloss"] = english if english.present?
        body["meaning_mizo"] = mizo if mizo.present?
      else
        content = (body["content"] ||= {})
        content["glosses"] = (content["glosses"] || {}).merge("en" => english) if english.present?
        content["definition_mizo"] = mizo if mizo.present?
      end
      body.dig("provenance")&.then { |provenance| provenance["notes"] = [ provenance["notes"], "Fixed in review: #{@notes}" ].compact.join(" ") }
      fixed = CreateRevision.call(content_item: @item, actor: @user, body: body, request_id: @request_id)
      SubmitRevision.call(revision: fixed, actor: @user, request_id: @request_id)
      Outcome.new("Fixed — the corrected revision now needs another reviewer.")
    end

    def drop(*)
      if @user.can_publish?
        ArchiveItem.call(content_item: @item, actor: @user, reason: "Dropped in flag review. #{@notes}".strip,
          request_id: @request_id)
        return Outcome.new("Dropped (archived).")
      end

      reject("Suggest dropping this word.")
      Outcome.new("Rejected with a suggestion to drop.")
    end

    private

    def reject(message)
      kind = @item.required_review_kinds.find { |candidate| @user.can_review?(candidate) }
      raise Error, "Your role cannot review this word." unless kind

      RecordDecision.call(revision: @revision, reviewer: @user, review_kind: kind, decision: "rejected",
        notes: [ message, @notes.presence ].compact.join(" · "), request_id: @request_id)
    end
  end
end
