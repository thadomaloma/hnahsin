Rails.application.config.permissions_policy do |policy|
  policy.camera :none
  policy.geolocation :none
  policy.microphone :none
  policy.payment :none
  policy.usb :none
end
