class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  def after_sign_in_path_for(resource)
    reminders_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  private

  def authenticate_user!
    unless user_signed_in?
      store_location_for(:user, request.fullpath)
      redirect_to root_path, alert: "ログインしてください"
    end
  end
end
