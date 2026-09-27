require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module ThumalQuestEditorial
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])
    config.time_zone = "Asia/Kolkata"
    config.active_record.default_timezone = :utc
    config.action_controller.default_protect_from_forgery = true
    config.generators.system_tests = nil
    config.filter_parameters += %i[password password_confirmation token]
  end
end
