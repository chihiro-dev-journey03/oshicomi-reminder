class RemindersController < ApplicationController
  before_action :authenticate_user!

  def index
    @reminders = current_user.reminders.includes(:book).order(scheduled_at: :asc)
  end
end
