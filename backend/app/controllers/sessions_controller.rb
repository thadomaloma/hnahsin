class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again in a few minutes." }

  def new
    redirect_to dashboard_path if current_user
  end

  def create
    user = User.authenticate_by(email: params[:email].to_s.strip.downcase, password: params[:password])
    user = nil unless user&.active?
    if user
      # Only a path on this site, so the login can't bounce somewhere else.
      return_to = session[:return_to].to_s
      return_to = dashboard_path unless return_to.start_with?("/") && !return_to.start_with?("//")
      reset_session
      cookies.signed[:editorial_user_id] = {
        value: user.id,
        httponly: true,
        same_site: :lax,
        secure: Rails.env.production?,
        expires: 12.hours.from_now
      }
      user.update_column(:last_signed_in_at, Time.current)
      redirect_to return_to, notice: "Welcome back."
    else
      redirect_to new_session_path, alert: "Email or password is incorrect."
    end
  end

  def destroy
    cookies.delete(:editorial_user_id)
    reset_session
    redirect_to new_session_path, notice: "Signed out safely."
  end
end
