class AddRecurrenceIntervalToReminders < ActiveRecord::Migration[7.2]
  def change
    add_column :reminders, :recurrence_interval, :integer, null: false, default: 1
  end
end
