class HealthController < ActionController::API
  def live
    no_store!
    render json: { status: "ok", service: "thumal-quest-editorial" }
  end

  def ready
    no_store!
    ActiveRecord::Base.connection.select_value("SELECT 1")
    render json: { status: "ready", database: "ok" }
  rescue StandardError => error
    Rails.logger.error("readiness_check_failed class=#{error.class.name}")
    render json: { status: "unavailable" }, status: :service_unavailable
  end

  private

  def no_store!
    response.headers["Cache-Control"] = "no-store"
  end
end
