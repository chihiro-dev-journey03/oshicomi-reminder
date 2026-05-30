class AddSentAtToReminders < ActiveRecord::Migration[7.2]
  def change
    add_column :reminders, :sent_at, :datetime
  end
end
