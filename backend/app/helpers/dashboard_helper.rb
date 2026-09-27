module DashboardHelper
  # Each icon is a duotone pair: a soft filled base shape (depth) plus a
  # bolder stroke layer (detail) drawn on top, rendered in a shared method
  # below so every icon in the app reads with the same layered weight.
  METRIC_ICONS = {
    draft: {
      fill: '<rect x="5" y="3.5" width="11" height="15" rx="2"/>',
      stroke: '<path d="M5 3.5h7l4 4v11a1 1 0 0 1-1 1H6a1 1 0 0 1-1-1v-15a1 1 0 0 1 1-1Z" stroke-linejoin="round"/><path d="M12 3.5v4h4" stroke-linejoin="round"/><path d="M8 11.5h5M8 14.5h3.5" stroke-linecap="round"/><path d="M15 15.5 20 20.5M20.5 15 15.5 20" stroke-linecap="round"/>'
    },
    review: {
      fill: '<circle cx="10.5" cy="10.5" r="6"/>',
      stroke: '<circle cx="10.5" cy="10.5" r="6.5"/><path d="m19.2 19.2-4.3-4.3" stroke-linecap="round"/><path d="M10.5 7.5v3l2.3 1.4" stroke-linecap="round" stroke-linejoin="round"/>'
    },
    approved: {
      fill: '<path d="M12 3 5 5.7v5.6c0 4.9 3 7.7 7 8.7 4-1 7-3.8 7-8.7V5.7L12 3Z"/>',
      stroke: '<path d="M12 3 5 5.7v5.6c0 4.9 3 7.7 7 8.7 4-1 7-3.8 7-8.7V5.7L12 3Z" stroke-linejoin="round"/><path d="m8.5 12.3 2.4 2.4 4.8-5.1" stroke-linecap="round" stroke-linejoin="round"/>'
    },
    published: {
      fill: '<circle cx="12" cy="12" r="7.5"/>',
      stroke: '<circle cx="12" cy="12" r="8"/><path d="M4 12h16" stroke-linecap="round"/><path d="M12 4c2.6 2.1 4 5 4 8s-1.4 5.9-4 8c-2.6-2.1-4-5-4-8s1.4-5.9 4-8Z" stroke-linejoin="round"/>'
    }
  }.freeze

  SECTION_ICONS = {
    queue: {
      fill: '<rect x="4.5" y="5.5" width="15" height="13" rx="2.5"/>',
      stroke: '<rect x="4.5" y="5.5" width="15" height="13" rx="2.5"/><path d="M8 10h8M8 13h8M8 16h5" stroke-linecap="round"/><circle cx="18.5" cy="5.5" r="2.5" fill="#b9873a" stroke="none"/>'
    },
    package: {
      fill: '<path d="M12 3 20 7.5v9L12 21 4 16.5v-9L12 3Z"/>',
      stroke: '<path d="M12 3 20 7.5v9L12 21 4 16.5v-9L12 3Z" stroke-linejoin="round"/><path d="M4 7.5 12 12l8-4.5M12 12v9" stroke-linejoin="round"/><path d="m8 5.3 8 4.5" stroke-linecap="round"/>'
    },
    activity: {
      fill: '<rect x="3.5" y="6" width="17" height="12" rx="3"/>',
      stroke: '<rect x="3.5" y="6" width="17" height="12" rx="3"/><path d="M6.5 12h2.3l1.7-4.5 3 9 1.7-4.5h2.3" stroke-linecap="round" stroke-linejoin="round"/>'
    },
    history: {
      fill: '<circle cx="12" cy="12.5" r="7.5"/>',
      stroke: '<circle cx="12" cy="12.5" r="8"/><path d="M12 8v4.5l3 2" stroke-linecap="round" stroke-linejoin="round"/><path d="M12 2.5v2M12 2.5h2.5M12 2.5h-2.5" stroke-linecap="round"/>'
    },
    rollback: {
      fill: '<path d="M12 4a8 8 0 1 1-7.4 5"/>',
      stroke: '<path d="M4.6 9A8 8 0 1 1 4 13" stroke-linecap="round"/><path d="M4 4.5V9h4.5" stroke-linecap="round" stroke-linejoin="round"/>'
    },
    inbox: {
      fill: '<path d="M4.5 12 7 5h10l2.5 7v6.5a1 1 0 0 1-1 1h-13a1 1 0 0 1-1-1V12Z"/>',
      stroke: '<path d="M4.5 12 7 5h10l2.5 7" stroke-linejoin="round"/><path d="M4.5 12h5l1.3 2.5h2.4L14.5 12h5" stroke-linejoin="round"/><path d="M4.5 12v6.5a1 1 0 0 0 1 1h13a1 1 0 0 0 1-1V12" stroke-linejoin="round"/>'
    }
  }.freeze

  ACTION_ICONS = {
    plus: {
      fill: '<rect x="3" y="3" width="18" height="18" rx="7"/>',
      stroke: '<rect x="3" y="3" width="18" height="18" rx="7"/><path d="M12 8.3v7.4M8.3 12h7.4" stroke-linecap="round"/>'
    },
    arrow_right: {
      fill: '<circle cx="12" cy="12" r="9"/>',
      stroke: '<circle cx="12" cy="12" r="9.5"/><path d="M7.5 12h9M13 8l4 4-4 4" stroke-linecap="round" stroke-linejoin="round"/>'
    },
    upload: {
      fill: '<path d="M7 17.5a4 4 0 0 1-.7-7.9 5.5 5.5 0 0 1 10.7-2 4.3 4.3 0 0 1 1.8 8.2v1.7H7Z"/>',
      stroke: '<path d="M7 17.5a4 4 0 0 1-.7-7.9 5.5 5.5 0 0 1 10.7-2 4.3 4.3 0 0 1 1.8 8.2H7Z" stroke-linejoin="round"/><path d="M12 20V11M9 14l3-3 3 3" stroke-linecap="round" stroke-linejoin="round"/>'
    },
    logout: {
      fill: '<rect x="3.5" y="3.5" width="9" height="17" rx="2"/>',
      stroke: '<path d="M9.5 3.5h-4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2h4" stroke-linecap="round" stroke-linejoin="round"/><path d="M16.5 16.5 21 12l-4.5-4.5" stroke-linecap="round" stroke-linejoin="round"/><path d="M21 12H9.5" stroke-linecap="round"/>'
    },
    edit: {
      fill: '<rect x="4" y="4" width="13" height="16" rx="2"/>',
      stroke: '<path d="M4.5 18v-13a1 1 0 0 1 1-1H14l5 5v9.5a1 1 0 0 1-1 1H5.5a1 1 0 0 1-1-1Z" stroke-linejoin="round"/><path d="m16 13.7 4.3 4.3-3.1.9.9-3.1Z" stroke-linejoin="round"/><path d="M8 8h6" stroke-linecap="round"/>'
    },
    person: {
      fill: '<circle cx="12" cy="8.5" r="3.5"/><path d="M5 20.5a7 7 0 0 1 14 0Z"/>',
      stroke: '<circle cx="12" cy="8.5" r="3.5"/><path d="M5 20.5a7 7 0 0 1 14 0" stroke-linecap="round"/>'
    }
  }.freeze

  def metric_icon(key)
    render_icon(METRIC_ICONS.fetch(key.to_sym, METRIC_ICONS[:draft]))
  end

  def section_icon(key)
    render_icon(SECTION_ICONS.fetch(key.to_sym, SECTION_ICONS[:queue]))
  end

  def action_icon(key)
    render_icon(ACTION_ICONS.fetch(key.to_sym, ACTION_ICONS[:arrow_right]))
  end

  def metric_tone(key)
    { draft: "slate", review: "amber", approved: "green", published: "gold" }.fetch(key.to_sym, "green")
  end

  private

  def render_icon(layers)
    raw(
      "<svg class=\"icon\" viewBox=\"0 0 24 24\" aria-hidden=\"true\">" \
      "<g fill=\"currentColor\" fill-opacity=\"0.16\" stroke=\"none\">#{layers[:fill]}</g>" \
      "<g fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.6\">#{layers[:stroke]}</g>" \
      "</svg>"
    )
  end
end
