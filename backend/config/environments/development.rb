require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  # Static files (editorial.css/js) have no explicit cache header otherwise,
  # so browsers can heuristically cache a stale copy across edits during
  # active development and hide changes until a hard refresh.
  config.public_file_server.headers = { "cache-control" => "no-cache" }
  config.consider_all_requests_local = true
  config.server_timing = true
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.action_controller.perform_caching = false
  config.active_support.deprecation = :log
end
