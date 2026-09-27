module Editorial
  # Adds or removes one game for many words at once. Each word gets a new
  # revision submitted for review, exactly like a single form edit.
  class BulkGameModes
    Result = Data.define(:changed, :skipped)
    OPERATIONS = %w[add remove].freeze

    def self.call(items:, game:, operation:, actor:, request_id: nil)
      raise Error, "editor role required" unless actor&.active? && actor.can_edit?
      raise Error, "Choose a game." unless BodyForm::GAME_MODES.key?(game)
      raise Error, "Choose add or remove." unless OPERATIONS.include?(operation)

      changed = 0
      skipped = []
      items.each do |item|
        next skipped << "#{item.stable_id} (not a word)" unless item.word?

        body = item.current_revision.body.deep_dup
        flat = body["word"].is_a?(String)
        modes = Array(flat ? body["game_modes"] : body.dig("learning", "game_modes"))
        updated = next_modes(modes, game, operation)
        next skipped << "#{item.stable_id} (#{updated})" if updated.is_a?(String)

        flat ? body["game_modes"] = updated : (body["learning"] ||= {})["game_modes"] = updated
        revision = CreateRevision.call(content_item: item, actor: actor, body: body, request_id: request_id)
        SubmitRevision.call(revision: revision, actor: actor, request_id: request_id)
        changed += 1
      end
      Result.new(changed: changed, skipped: skipped)
    end

    # Returns the new tag list, or a reason string when nothing should change.
    # An empty list means "every game", so removing from it lists the rest.
    def self.next_modes(modes, game, operation)
      all = BodyForm::GAME_MODES.keys
      if operation == "add"
        return "already in every game" if modes.empty?
        return "already tagged" if modes.include?(game)

        (modes + [ game ]).then { |list| all.select { |mode| list.include?(mode) } }
      else
        current = modes.empty? ? all : modes
        return "not tagged" unless current.include?(game)
        return "it would be left in no game" if current == [ game ]

        current - [ game ]
      end
    end
  end
end
