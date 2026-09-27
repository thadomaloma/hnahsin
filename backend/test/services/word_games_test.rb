require "test_helper"

class WordGamesTest < ActiveSupport::TestCase
  def word(overrides = {})
    {
      "content" => { "canonical_form" => "Sakei", "definition_mizo" => "Ramsa hlauhawm.",
                     "glosses" => { "en" => "tiger" }, "example_mizo" => "Sakei a tlan.", "emoji" => "🐅" },
      "learning" => { "difficulty" => 2, "game_modes" => [] },
      "category" => "nungcha"
    }.deep_merge(overrides)
  end

  test "untagged words play everywhere their shape fits" do
    games = Editorial::WordGames.for("word.sakei", word).games
    assert_equal Editorial::WordGames::GAMES.keys.sort, games.sort
  end

  test "tags limit games and shape rules still apply" do
    long = word("content" => { "canonical_form" => "Tlawmngaihna", "emoji" => "" },
                "learning" => { "game_modes" => %w[crossword word_search tawng_upa picture_match] })
    assert_equal %w[tawng_upa], Editorial::WordGames.for("word.x", long).games
  end

  test "incomplete words are in no game" do
    incomplete = word("content" => { "example_mizo" => "" })
    assert_empty Editorial::WordGames.for("word.sakei", incomplete).games
  end

  test "bulk add and remove respect the every-game meaning of empty tags" do
    assert_equal "already in every game", Editorial::BulkGameModes.next_modes([], "crossword", "add")
    assert_not_includes Editorial::BulkGameModes.next_modes([], "crossword", "remove"), "crossword"
    assert_equal %w[spelling crossword], Editorial::BulkGameModes.next_modes(%w[spelling], "crossword", "add")
    assert_equal "it would be left in no game", Editorial::BulkGameModes.next_modes(%w[spelling], "spelling", "remove")
  end
end
