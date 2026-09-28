module ApplicationHelper
  include Pagy::Frontend

  def initials_for(text)
    text.to_s.scan(/[A-Za-z0-9]/).first(2).join.upcase.presence || "·"
  end

  ROLE_TONES = {
    "admin" => "role-admin",
    "publisher" => "role-publisher",
    "editor" => "role-editor"
  }.freeze

  def role_pill_class(role)
    ROLE_TONES.fetch(role.to_s, "role-reviewer")
  end

  # The game build the Studio serves itself (scripts/build_game_test.sh), or
  # the `flutter run` web server that run_local.command starts.
  def flutter_web_test_url
    ENV.fetch("FLUTTER_WEB_TEST_URL") do
      Rails.public_path.join("game-test", "index.html").exist? ? "/game-test/" : "http://localhost:5050"
    end
  end
end
