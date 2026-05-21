class Reminder < ApplicationRecord
  belongs_to :user
  belongs_to :book

  attr_accessor :book_title

  RECURRENCE_TYPES = %w[daily weekly monthly].freeze

  # 曜日ビットマスク定数（日=0bit目, 月=1bit目, ..., 土=6bit目）
  DAYS_OF_WEEK_BITS = {
    0 => "日", 1 => "月", 2 => "火", 3 => "水", 4 => "木", 5 => "金", 6 => "土"
  }.freeze

  enum :status, { pending: 0, sent: 1, failed: 2 }

  validates :recurrence_type, inclusion: { in: RECURRENCE_TYPES }
  validates :time_hour,   presence: true, numericality: { in: 0..23 }
  validates :time_minute, presence: true, numericality: { in: 0..59 }
  validates :days_of_week, presence: true, if: -> { recurrence_type == "weekly" }
  validates :day_of_month, presence: true, numericality: { in: 1..31 },
                           if: -> { recurrence_type == "monthly" && monthly_type == "date" }
  validates :week_of_month, presence: true, numericality: { in: 1..5 },
                            if: -> { recurrence_type == "monthly" && monthly_type == "weekday" }
  validates :weekday, presence: true, numericality: { in: 0..6 },
                      if: -> { recurrence_type == "monthly" && monthly_type == "weekday" }

  # 曜日ビットマスクのセッター（配列 → 整数）
  def days_of_week_array=(array)
    self.days_of_week = Array(array).reject(&:blank?).sum { |d| 1 << d.to_i }
  end

  # 曜日ビットマスクのゲッター（整数 → 配列）
  def days_of_week_array
    return [] if days_of_week.nil?

    (0..6).select { |d| days_of_week & (1 << d) > 0 }
  end

  # 一覧表示用の繰り返しスケジュールサマリー
  def schedule_summary
    time = format("%02d:%02d", time_hour, time_minute)
    case recurrence_type
    when "daily"
      "毎日 #{time}"
    when "weekly"
      days = days_of_week_array.map { |d| DAYS_OF_WEEK_BITS[d] }.join("・")
      days_label = days.present? ? "#{days} " : ""
      "毎週 #{days_label}#{time}"
    when "monthly"
      if monthly_type == "weekday"
        week_names = %w[第1 第2 第3 第4 第5]
        day_names = %w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日 土曜日]
        week_label = week_of_month ? week_names[week_of_month - 1] : ""
        day_label  = weekday ? day_names[weekday] : ""
        "毎月#{week_label}#{day_label} #{time}"
      else
        "毎月#{day_of_month}日 #{time}"
      end
    else
      time
    end
  end
end
