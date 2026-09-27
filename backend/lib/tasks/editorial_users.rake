namespace :editorial do
  desc "Create or update one Editorial Studio user from EMAIL, PASSWORD and ROLE"
  task upsert_user: :environment do
    email = ENV.fetch("EMAIL")
    password = ENV.fetch("PASSWORD")
    role = ENV.fetch("ROLE")
    abort "ROLE must be one of: #{User.roles.keys.join(', ')}" unless User.roles.key?(role)

    user = User.find_or_initialize_by(email: email)
    user.assign_attributes(password: password, role: role, active: true)
    user.save!
    Audit::Record.call(
      actor: nil,
      auditable: user,
      action: "editorial_user.upserted",
      metadata: { role: role, source: "rake" }
    )
    puts "Editorial user ready: #{user.email} (#{user.role})"
  end

  desc "Disable an Editorial Studio user by EMAIL"
  task disable_user: :environment do
    user = User.find_by!(email: ENV.fetch("EMAIL").strip.downcase)
    user.update!(active: false)
    Audit::Record.call(
      actor: nil,
      auditable: user,
      action: "editorial_user.disabled",
      metadata: { source: "rake" }
    )
    puts "Editorial user disabled: #{user.email}"
  end
end
