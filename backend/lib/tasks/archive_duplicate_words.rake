namespace :editorial do
  # Hand-checked 2026-09-27: each entry spells exactly the same word as the
  # kept item with the same meaning. Same-spelling homonyms with different
  # meanings (lei, bial, choka, hniak, anṭam, in.drink, lo.come, tho.rise)
  # are deliberately NOT listed.
  DUPLICATE_WORDS = {
    "word.ha-2" => "duplicate of word.ha (tooth)",
    "word.beram" => "duplicate of word.beram-2 (sheep)",
    "word.chinghne" => "duplicate of published word.chinghne-2 (wolf)",
    "word.nui-3" => "duplicate of word.nui (smile/laugh)",
    "word.balhla-3" => "duplicate of word.balhla (banana)",
    "word.hnim" => "duplicate of published word.hnim-3 (smell)",
    "word.ral-3" => "duplicate of word.ral-2 (enemy/war)",
    "word.sazuk" => "duplicate of published word.sazuk-3 (deer); its gloss conflicted",
    "word.ar" => "empty pilot row; word.ar-2 carries the reviewed content (chicken)",
    "word.chak" => "empty pilot row; word.chak-2 carries the reviewed content (strong)",
    "word.in.house" => "empty pilot row; word.in carries the reviewed content (house)",
    "word.ni.sun" => "empty pilot row; word.ni carries the reviewed content (sun)",
    "word.thla.moon" => "empty pilot row; word.thla carries the reviewed content (moon)",
    "word.sa.meat" => "empty pilot row; word.sa carries the reviewed content (meat)"
  }.freeze

  desc "Archive hand-checked duplicate words so the next content pack leaves them out"
  task archive_duplicate_words: :environment do
    actor_email = ENV.fetch("ARCHIVE_ACTOR_EMAIL", "publisher@local.test")
    actor = User.find_by(email: actor_email)
    abort "No user found for #{actor_email.inspect}. Set ARCHIVE_ACTOR_EMAIL." unless actor

    archived = 0
    missing = []
    DUPLICATE_WORDS.each do |stable_id, reason|
      item = ContentItem.find_by(stable_id: stable_id)
      next missing << stable_id unless item
      next if item.status_archived?

      Editorial::ArchiveItem.call(content_item: item, actor: actor, reason: reason)
      archived += 1
    end

    puts "Archived: #{archived} (#{DUPLICATE_WORDS.size - archived - missing.size} already archived)"
    puts "Not found: #{missing.join(", ")}" if missing.any?
    puts "Publish a new pack (editorial:publish_content_pack) so the app drops them."
  end
end
