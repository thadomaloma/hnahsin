module Editorial
  # Turns the structured Editorial Studio forms into revision bodies (and back
  # into form values), so editors never have to hand-write JSON for the
  # content the mobile games read. Fields the form doesn't manage (provenance,
  # rights, notes…) are carried over unchanged from the base revision.
  class BodyForm
    STRUCTURED_TYPES = %w[word question game_copy sentence].freeze
    CATEGORIES = {
      "chhungkua" => "Family", "sikul" => "School", "nungcha" => "Animals",
      "khawvel" => "Nature", "nunphung" => "Culture", "thiltih" => "Actions"
    }.freeze
    GAME_MODES = {
      "picture_match" => "Picture Match", "spelling" => "Spelling",
      "word_search" => "Word Search", "word_chain" => "Word Chain",
      "tawng_upa" => "Tawng Upa", "crossword" => "Crossword",
      "thumal_kawp" => "Thumal Kawp", "sentence_builder" => "Sentence Builder"
    }.freeze
    GAMES = GAME_MODES.merge("common" => "All games (shared feedback)").freeze

    def self.structured?(content_type) = STRUCTURED_TYPES.include?(content_type.to_s)

    def self.build(content_type:, fields:, base: nil, image: nil, actor: nil)
      new(content_type.to_s, fields.to_h.stringify_keys, base&.deep_dup || {}, image, actor).build
    end

    def self.values(content_type:, body:)
      new(content_type.to_s, {}, body || {}, nil, nil).values
    end

    def initialize(content_type, fields, base, image, actor)
      @type = content_type
      @fields = fields
      @body = base
      @image = image
      @actor = actor
    end

    def build
      case @type
      when "word" then build_word
      when "question" then build_question
      when "game_copy" then build_game_copy
      when "sentence" then build_sentence
      else raise Error, "#{@type.humanize} content is edited as JSON."
      end
      @body["updated_at"] = Time.current.iso8601 if @body.key?("updated_at")
      @body
    end

    def values
      case @type
      when "word" then word_values
      when "question" then @body.slice("prompt_mizo", "answer", "explanation_mizo", "emoji", "difficulty")
        .merge("options" => Array(@body["options"]))
      when "game_copy"
        @body.slice("game_id", "title", "subtitle", "prompt", "hint", "correct_feedback", "retry_feedback")
          .merge("instructions" => Array(@body["instructions"]).join("\n"))
      when "sentence"
        content = @body["content"].is_a?(Hash) ? @body["content"] : @body
        { "text_mizo" => content["text_mizo"], "english_support" => content["english_support"],
          "difficulty" => @body.dig("learning", "difficulty") || @body["difficulty"] }
      else {}
      end
    end

    private

    def text(key) = @fields[key].to_s.strip

    def required(key, label)
      value = text(key)
      raise Error, "#{label} is required." if value.empty?

      value
    end

    def difficulty
      value = Integer(@fields["difficulty"].presence || 1, exception: false)
      raise Error, "Level must be between 1 and 7." unless value&.between?(1, 7)

      value
    end

    def game_modes
      Array(@fields["game_modes"]).map(&:to_s).select { |mode| GAME_MODES.key?(mode) }
    end

    # --- word -------------------------------------------------------------

    def build_word
      word = required("word", "Word")
      category = text("category")
      raise Error, "Choose a category." unless CATEGORIES.key?(category)

      if @body["word"].is_a?(String)
        # Flat delivery shape (older Studio-created words).
        @body.merge!("word" => word, "meaning_mizo" => required("meaning_mizo", "Mizo meaning"),
          "english_gloss" => required("english_gloss", "English meaning"),
          "example_mizo" => required("example_mizo", "Example sentence"),
          "emoji" => text("emoji").presence, "category" => category, "difficulty" => difficulty,
          "game_modes" => game_modes)
        apply_image(@body)
      else
        @body["schema_version"] ||= "2.0"
        @body["type"] ||= "word"
        @body["language"] ||= "lus"
        content = (@body["content"] ||= {})
        content["canonical_form"] = word
        content["normalized_search"] = word.downcase
        content["definition_mizo"] = required("meaning_mizo", "Mizo meaning")
        content["glosses"] = (content["glosses"] || {}).merge("en" => required("english_gloss", "English meaning"))
        content["example_mizo"] = required("example_mizo", "Example sentence")
        content["emoji"] = text("emoji").presence
        apply_image(content)
        learning = (@body["learning"] ||= {})
        learning["difficulty"] = difficulty
        learning["game_modes"] = game_modes
        @body["category"] = category
      end
    end

    def apply_image(target)
      target.delete("image") if @fields["remove_image"] == "1"
      return if @image.blank?

      target["image"] = WordImage.store!(@image, uploaded_by: @actor).reference
    end

    def word_values
      if @body["word"].is_a?(String)
        return @body.slice("word", "meaning_mizo", "english_gloss", "example_mizo", "emoji", "category", "difficulty")
          .merge("game_modes" => Array(@body["game_modes"]), "image" => @body["image"])
      end

      content = @body["content"] || {}
      learning = @body["learning"] || {}
      {
        "word" => content["canonical_form"], "meaning_mizo" => content["definition_mizo"],
        "english_gloss" => content.dig("glosses", "en"), "example_mizo" => content["example_mizo"],
        "emoji" => content["emoji"],
        "category" => @body["category"] || SeedCategories.for(learning["categories"]),
        "difficulty" => learning["difficulty"],
        "game_modes" => Array(learning["game_modes"]), "image" => content["image"]
      }
    end

    # --- Tawng Upa question ------------------------------------------------

    def build_question
      options = Array(@fields["options"]).map { |option| option.to_s.strip }.reject(&:empty?)
      raise Error, "A question needs exactly four different options." unless options.size == 4 && options.uniq.size == 4

      answer = required("answer", "Correct answer")
      raise Error, "The correct answer must be one of the four options." unless options.include?(answer)

      @body.merge!(
        "type" => "question", "game" => "tawng_upa", "language" => "lus",
        "prompt_mizo" => required("prompt_mizo", "Question"), "options" => options, "answer" => answer,
        "explanation_mizo" => required("explanation_mizo", "Explanation"),
        "emoji" => text("emoji").presence || "💬", "difficulty" => difficulty
      )
    end

    # --- per-game copy -----------------------------------------------------

    def build_game_copy
      game = text("game_id")
      raise Error, "Choose a game." unless GAMES.key?(game)

      instructions = @fields["instructions"].to_s.lines.map(&:strip).reject(&:empty?)
      copy = { "type" => "game_copy", "language" => "lus", "game_id" => game }
      %w[title subtitle prompt hint correct_feedback retry_feedback].each do |key|
        copy[key] = text(key).presence
      end
      copy["instructions"] = instructions
      @body.merge!(copy.compact)
      %w[title subtitle prompt hint correct_feedback retry_feedback].each { |key| @body.delete(key) if copy[key].nil? }
    end

    # --- Sentence Builder sentence -----------------------------------------

    def build_sentence
      sentence = required("text_mizo", "Mizo sentence")
      raise Error, "A sentence needs at least two words to arrange." if sentence.split.size < 2

      content = (@body["content"] ||= {})
      content["text_mizo"] = sentence
      content["english_support"] = required("english_support", "English meaning")
      (@body["learning"] ||= {})["difficulty"] = difficulty
      @body["type"] ||= "sentence"
      @body["language"] ||= "lus"
    end
  end
end
