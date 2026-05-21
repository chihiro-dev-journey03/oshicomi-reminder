class ChangeRemindersForRecurrence < ActiveRecord::Migration[7.2]
  def change
    # 繰り返し設定用カラムを追加
    add_column :reminders, :recurrence_type, :string, null: false, default: "daily"
    add_column :reminders, :time_hour,       :integer, null: false, default: 9
    add_column :reminders, :time_minute,     :integer, null: false, default: 0
    add_column :reminders, :days_of_week,    :integer, default: 0   # 週ごと：曜日ビットマスク（日=1,月=2,火=4,水=8,木=16,金=32,土=64）
    add_column :reminders, :day_of_month,    :integer               # 月ごと（日付指定）：何日か
    add_column :reminders, :monthly_type,    :string                # "date" or "weekday"
    add_column :reminders, :week_of_month,   :integer               # 月ごと（曜日指定）：第何週か
    add_column :reminders, :weekday,         :integer               # 月ごと（曜日指定）：何曜日か

    # 1回限りの日時カラムを削除
    remove_column :reminders, :scheduled_at, :datetime
    remove_column :reminders, :sent_at,      :datetime
  end
end
