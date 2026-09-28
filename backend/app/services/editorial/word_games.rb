module Editorial
  # Which games a word actually appears in, using the same rules as the
  # mobile app (lib/src/games.dart and friends): the word must be complete,
  # tagged for the game (no tags = every game) and fit the game's shape —
  # e.g. Picture Match needs a picture, Crossword needs 3–7 plain letters.
  class WordGames
    GAMES = BodyForm::GAME_MODES
    ILLUSTRATIONS = Rails.root.join("..", "assets", "illustrations")

    attr_reader :item_id, :word, :meaning, :gloss, :example, :difficulty, :modes

    def self.for(stable_id, body, item_id: nil) = new(stable_id, body || {}, item_id)

    # Every non-archived word with its latest revision (one query).
    def self.catalog
      ContentRevision
        .joins(:content_item)
        .merge(ContentItem.where(content_type: :word).where.not(status: :archived))
        .select("DISTINCT ON (content_revisions.content_item_id) content_revisions.content_item_id, " \
                "content_revisions.body, content_items.stable_id AS item_stable_id")
        .order("content_revisions.content_item_id, content_revisions.number DESC")
        .map { |row| self.for(row.item_stable_id, row.body, item_id: row.content_item_id) }
    end

    def initialize(stable_id, body, item_id = nil)
      @item_id = item_id
      @stable_id = stable_id
      values = BodyForm.values(content_type: "word", body: body)
      @word = values["word"].to_s.strip
      @meaning = values["meaning_mizo"].to_s.strip
      @gloss = values["english_gloss"].to_s.strip
      @example = values["example_mizo"].to_s.strip
      @emoji = values["emoji"].to_s.strip
      @image = values["image"]
      @category = values["category"]
      @difficulty = values["difficulty"]
      @modes = Array(values["game_modes"])
    end

    # Words missing any learner-facing field are left out of the app entirely.
    def complete?
      [ @word, @meaning, @gloss, @example ].all?(&:present?) &&
        BodyForm::CATEGORIES.key?(@category) && @difficulty.is_a?(Integer) && @difficulty.between?(1, 7)
    end

    def picture?
      @image.is_a?(Hash) || @emoji.present? || bundled_illustration?
    end

    def games
      return [] unless complete?

      GAMES.keys.select { |game| plays?(game) }
    end

    def plays?(game)
      return false unless @modes.empty? || @modes.include?(game)

      letters = @word.length
      case game
      when "picture_match" then picture?
      when "spelling" then letters >= 2
      when "word_search" then letters.between?(2, 6) && !@word.include?(" ")
      # One letter per cell, spelled with the on-screen Mizo keyboard.
      when "crossword" then letters.between?(3, 7) && MIZO_LETTERS.match?(@word.downcase)
      when "word_chain" then MIZO_LETTERS.match?(@word.downcase)
      when "thumal_kawp" then picture? || @gloss.length <= 22
      # The example must actually use the word it teaches.
      when "sentence_builder" then @example.split.size >= 2 && fold(@example).include?(fold(@word.split.first.to_s))
      else true
      end
    end

    MIZO_LETTERS = /\A[a-zâêîôûṭ]+\z/

    def fold(text) = text.downcase.tr("âêîôûṭ", "aeiout")

    private

    def bundled_illustration?
      ILLUSTRATIONS.join("#{@stable_id}.png").exist? ||
        ILLUSTRATIONS.join("word.#{@word.downcase}.png").exist?
    end
  end
end
