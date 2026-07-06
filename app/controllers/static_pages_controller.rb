class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!

  def top
    redirect_to reminders_path if user_signed_in?
  end

  def register
    redirect_to reminders_path if user_signed_in?
  end

  def login
    redirect_to reminders_path if user_signed_in?
  end
end
