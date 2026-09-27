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

  def flutter_web_test_url
    ENV.fetch("FLUTTER_WEB_TEST_URL", "http://localhost:5050")
  end

  def brand_favicon_data_uri
    svg = <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 40 40">
        <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stop-color="#0a7c72"/>
          <stop offset="1" stop-color="#062f2b"/>
        </linearGradient></defs>
        <rect width="40" height="40" rx="11" fill="url(#g)"/>
        <text x="20" y="26" font-family="-apple-system,Helvetica,Arial,sans-serif" font-size="15" font-weight="800" fill="#fff" text-anchor="middle">TQ</text>
      </svg>
    SVG
    "data:image/svg+xml,#{ERB::Util.url_encode(svg)}"
  end
end
