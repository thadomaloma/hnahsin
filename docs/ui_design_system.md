# Hnahsin UI design system

Version 0.4 (2026-09-27) refreshes the visual layer; version 0.3 defined a production-oriented mobile system that can be recreated
as Figma components without changing the Flutter information architecture.

## Language hierarchy

- Navigation, page names, section names, filters, buttons, score labels, and
  status labels use natural English.
- Mizo remains the primary language for lesson prompts, examples, meanings,
  feedback, and cultural content.
- Product names such as **Hnahsin** and **Tawng Upa** remain unchanged.

## Core tokens

| Token | Value | Use |
| --- | --- | --- |
| Midnight | `#07162F` | Hero surfaces |
| Navy | `#102A56` | Brand depth |
| Indigo | `#3152B7` | Primary action |
| Teal | `#39D6C4` | Progress/accent |
| Gold | `#FFC94A` | Reward/highlight |
| Canvas | `#F5F7FB` | App background |
| Ink | `#15213A` | Primary text |
| Slate | `#667085` | Secondary text |
| Line | `#E4E9F0` | Borders/dividers |

Spacing follows a compact 8-point rhythm, with 6/10/16/24/32 pixel tokens for
optical adjustment. Corner radii are 12, 18, 24, and 30 pixels.

## Typography

Plus Jakarta Sans (SIL OFL, bundled in `assets/fonts/` as static 400–800
weights) is the only typeface. It covers every Mizo letter, including ṭ/Ṭ
and circumflex vowels, so no platform falls back to another font.

## Responsive layout

`QuestLayout` in `lib/src/theme.dart` is the single source of truth:

| Width | Class | Navigation | Gutter | Game grid |
| --- | --- | --- | --- | --- |
| < 360 | compact (small phone) | floating bottom bar | 14 | 2 columns |
| 360–599 | compact (phone) | floating bottom bar | 18 | 2 columns |
| 600–839 | medium (foldable / small tablet) | floating bottom bar | 28 | 3 columns |
| ≥ 840 | medium / expanded (tablet, desktop) | navy side rail | 28–36 | 3–4 columns |

Tab content is centred at a 960-pixel maximum; game pages at 720. System
text scaling is honoured up to 1.35×.

## Component inventory

- Floating navigation: frosted-glass bar with a navy gradient selected pill (phones); navy side rail (≥ 840 px)
- Page intro: eyebrow, title, subtitle, optional trailing component
- Premium card: 24-pixel radius, subtle border, low-elevation shadow
- Hero card: three-stop navy gradient with daily progress ring
- Icon tile: 54-pixel tonal container using Material symbols
- Game card: icon, completion state, description, best score, action cue
- Game HUD: navy gradient bar with heart icons, timer/combo/score chips and a teal→gold progress bar
- Game stage: framed, softly lit prompt area at the top of each round
- Game card: pastel gradient art header, play chip and best-score badge
- Answer state: default, selected, correct, and incorrect — lettered badge (A–D), press animation and coloured glow
- Result sheet: star rating, score, accuracy, XP, and primary action

## Screen hierarchy

1. **Home** — brand, daily quest, daily challenge, popular games
2. **Learn** — course path, word library, lesson progression
3. **Games** — eight-game practice arena with completion and best score
4. **Profile** — level, XP, streak, completion, learning-track selector

## Accessibility baseline

- Primary controls have a minimum height of 54 pixels.
- Meaning is never communicated by color alone.
- Selected, correct, incorrect, and completed states include icons.
- Text contrast uses dark ink on light surfaces and white on dark hero cards.
- Mizo diacritics remain Unicode text and are not converted into image labels.
