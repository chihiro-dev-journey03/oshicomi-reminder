class RemindersController < ApplicationController
  before_action :authenticate_user!

  def index
    @reminders = current_user.reminders.includes(:book).order(created_at: :desc)
  end

  def new
    @reminder = Reminder.new(
      recurrence_type: "daily", recurrence_interval: 1,
      time_hour: 9, time_minute: 0,
      monthly_type: "date", day_of_month: 1, week_of_month: 1, weekday: 0
    )
  end

  def create
    book_title = params.dig(:reminder, :book_title)&.strip

    if book_title.blank?
      @reminder = current_user.reminders.build(reminder_params)
      @reminder.errors.add(:base, "マンガタイトルを入力してください")
      return render :new, status: :unprocessable_entity
    end

    book = Book.find_or_create_by_base_title(book_title)
    @reminder = current_user.reminders.build(reminder_params)
    @reminder.book = book
    @reminder.days_of_week_array = params.dig(:reminder, :days_of_week_array) || []

    if @reminder.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to reminders_path, notice: "リマインダーを登録しました" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @reminder = current_user.reminders.find(params[:id])
  end

  def destroy
    @reminder = current_user.reminders.find(params[:id])
    @reminder.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to reminders_path, notice: "リマインダーを削除しました" }
    end
  end

  def update
    @reminder = current_user.reminders.find(params[:id])
    book_title = params.dig(:reminder, :book_title)&.strip

    if book_title.blank?
      @reminder.assign_attributes(reminder_params)
      @reminder.errors.add(:base, "マンガタイトルを入力してください")
      return render :edit, status: :unprocessable_entity
    end

    book = Book.find_or_create_by_base_title(book_title)
    @reminder.assign_attributes(reminder_params)
    @reminder.book = book
    @reminder.days_of_week_array = params.dig(:reminder, :days_of_week_array) || []

    if @reminder.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to reminders_path, notice: "リマインダーを更新しました" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def reminder_params
    params.require(:reminder).permit(
      :recurrence_type,
      :recurrence_interval,
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
