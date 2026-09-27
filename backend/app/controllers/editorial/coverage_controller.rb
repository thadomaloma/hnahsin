module Editorial
  # How many live (published) items each game can draw from at each level, so
  # editors can see where a game would run thin before learners notice.
  class CoverageController < BaseController
    LOW = 5
    LEVELS = (1..7).to_a

    def show
      @games = WordGames::GAMES
      @live = @games.keys.index_with { Hash.new(0) }
      ContentItem.where(content_type: :word).where.not(published_revision_id: nil)
        .where.not(status: :archived).includes(:published_revision).find_each do |item|
        words = WordGames.for(item.stable_id, item.published_revision.body)
        words.games.each { |game| @live[game][words.difficulty] += 1 }
      end
      live_extras("question", "tawng_upa") { |body| body["difficulty"] }
      live_extras("sentence", "sentence_builder") do |body|
        body.dig("learning", "difficulty") || body.dig("learning", "tq_level").to_s[/\d+/]&.to_i&.+(1)
      end
      @pending = WordGames.catalog.each_with_object(Hash.new(0)) { |w, counts| w.games.each { |g| counts[g] += 1 } }
      @low = LOW
      @levels = LEVELS
    end

    private

    def live_extras(content_type, game)
      ContentItem.where(content_type: content_type).where.not(published_revision_id: nil)
        .includes(:published_revision).find_each do |item|
        level = yield(item.published_revision.body).to_i.clamp(1, 7)
        @live[game][level] += 1
      end
    end
  end
end
