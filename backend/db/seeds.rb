email = ENV["EDITORIAL_ADMIN_EMAIL"]
password = ENV["EDITORIAL_ADMIN_PASSWORD"]

if email.present? && password.present?
  admin = User.find_or_initialize_by(email: email)
  admin.assign_attributes(password: password, role: :admin, active: true)
  admin.save!
  puts "Editorial admin is ready: #{admin.email}"
else
  puts "No admin seeded. Set EDITORIAL_ADMIN_EMAIL and EDITORIAL_ADMIN_PASSWORD."
end
