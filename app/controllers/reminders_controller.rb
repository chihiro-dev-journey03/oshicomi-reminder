class RemindersController < ApplicationController
  before_action :authenticate_user!

  def index
    @reminders = current_user.reminders.includes(:book).order(created_at: :desc)
  end
end
