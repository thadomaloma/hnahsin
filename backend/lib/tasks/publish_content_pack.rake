namespace :editorial do
  desc "Publish every currently-approved content item into a new content pack " \
       "release. Requires PACK_VERSION=x.y.z (semantic version). Items still " \
       "in_review or draft (e.g. VERIFY-flagged or culture-sensitive content " \
       "awaiting a real reviewer) are left out -- run this again after they " \
       "clear review to include them in a later pack."
  task publish_content_pack: :environment do
    publisher_email = ENV.fetch("PUBLISH_PUBLISHER_EMAIL", "publisher@local.test")
    publisher = User.find_by(email: publisher_email)
    unless publisher
      abort "No user found for #{publisher_email.inspect}. " \
            "Set PUBLISH_PUBLISHER_EMAIL=you@example.com and re-run."
    end
    unless publisher.can_publish?
      abort "#{publisher.email} (role: #{publisher.role}) is not authorized to publish. " \
            "Use a user with role admin or publisher."
    end

    pack_version = ENV.fetch("PACK_VERSION") do
      abort "Set PACK_VERSION=x.y.z (semantic version) and re-run."
    end

    begin
      pack = Editorial::PublishPack.call(
        pack_version: pack_version,
        actor: publisher
      )
    rescue Editorial::Error => e
      abort "Publish failed: #{e.message}"
    end

    puts "Published pack #{pack.public_id} (version #{pack.pack_version})"
    puts "Items included: #{pack.content_pack_entries.count}"
    puts "Checksum: #{pack.checksum}"
  end
end
