class RemindersController < ApplicationController
  before_action :authenticate_user!

  def index
    @reminders = current_user.reminders.includes(:book).order(created_at: :desc)
  end

  def new
    @reminder = Reminder.new(recurrence_type: "daily", time_hour: 9, time_minute: 0, monthly_type: "date", day_of_month: 1)
  end

  def create
    book_title = params.dig(:reminder, :book_title)&.strip

    if book_title.blank?
      @reminder = current_user.reminders.build(reminder_params)
      @reminder.errors.add(:book_title, "を入力してください")
      return render :new, status: :unprocessable_entity
    end

    book = Book.find_or_create_by(title: book_title)
    @reminder = current_user.reminders.build(reminder_params)
    @reminder.book = book
    @reminder.days_of_week_array = params.dig(:reminder, :days_of_week_array) || []

    if @reminder.save
      redirect_to reminders_path, notice: "リマインダーを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def reminder_params
    params.require(:reminder).permit(
      :recurrence_type,
      :time_hour,
      :time_minute,
      :day_of_month,
      :monthly_type,
      :week_of_month,
      :weekday,
      :memo
    )
  end
end
