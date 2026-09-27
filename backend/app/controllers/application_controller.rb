class ApplicationController < ActionController::Base
  include Pagy::Backend

  protect_from_forgery with: :exception
  before_action :require_authentication

  helper_method :current_user

  rescue_from Editorial::Error, with: :render_editorial_error
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.active.find_by(id: cookies.signed[:editorial_user_id])
  end

  def require_authentication
    redirect_to new_session_path, alert: "Sign in to open Editorial Studio." unless current_user
  end

  def require_roles!(*roles)
    return if current_user&.role_admin? || roles.any? { |role| current_user&.public_send("role_#{role}?") }

    redirect_to dashboard_path, alert: "Your role does not allow that action."
  end

  def render_editorial_error(error)
    respond_to do |format|
      format.json { render json: { error: error.message }, status: :unprocessable_content }
      format.html { redirect_back fallback_location: dashboard_path, alert: error.message }
    end
  end

  def render_record_invalid(error)
    message = error.record.errors.full_messages.to_sentence
    respond_to do |format|
      format.json { render json: { error: message }, status: :unprocessable_content }
      format.html { redirect_back fallback_location: dashboard_path, alert: message }
    end
  end
end
