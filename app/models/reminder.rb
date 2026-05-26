class Reminder < ApplicationRecord
  belongs_to :user
  belongs_to :book

  attr_accessor :book_title

  RECURRENCE_TYPES = %w[daily weekly monthly].freeze

  # 曜日ビットマスク定数（日=0bit目, 月=1bit目, ..., 土=6bit目）
  DAYS_OF_WEEK_BITS = {
    0 => "日", 1 => "月", 2 => "火", 3 => "水", 4 => "木", 5 => "金", 6 => "土"
  }.freeze

  # 繰り返し間隔の上限（日ごと:99日, 週ごと:52週, ヶ月ごと:12ヶ月）
  INTERVAL_MAX = { "daily" => 99, "weekly" => 52, "monthly" => 12 }.freeze

  enum :status, { pending: 0, sent: 1, failed: 2 }

  validates :recurrence_type, inclusion: { in: RECURRENCE_TYPES }
  validates :recurrence_interval, presence: true,
                                  numericality: { only_integer: true, greater_than: 0 }
  validate :recurrence_interval_within_max
  validates :time_hour,   presence: true, numericality: { in: 0..23 }
  validates :time_minute, presence: true, numericality: { in: 0..59 }
  validates :days_of_week, numericality: { greater_than: 0, message: "を1つ以上選択してください" },
                           if: -> { recurrence_type == "weekly" }
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
    time     = format("%02d:%02d", time_hour, time_minute)
    interval = recurrence_interval || 1
    case recurrence_type
    when "daily"
      interval == 1 ? "毎日 #{time}" : "#{interval}日ごと #{time}"
    when "weekly"
      days   = days_of_week_array.map { |d| DAYS_OF_WEEK_BITS[d] }.join("・")
      prefix = interval == 1 ? "毎週" : "#{interval}週ごと"
      days.present? ? "#{prefix} #{days} #{time}" : "#{prefix} #{time}"
    when "monthly"
      prefix = interval == 1 ? "毎月" : "#{interval}ヶ月ごと"
      if monthly_type == "weekday"
        week_names = %w[最初の 第二 第三 第四 最後の]
        day_names  = %w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日 土曜日]
        week_label = week_of_month ? week_names[week_of_month - 1] : ""
        day_label  = weekday ? day_names[weekday] : ""
        "#{prefix}#{week_label}#{day_label} #{time}"
      else
        "#{prefix}#{day_of_month}日 #{time}"
      end
    else
      time
    end
  end

  private

  def recurrence_interval_within_max
    return unless recurrence_type.present? && recurrence_interval.present?

    max = INTERVAL_MAX[recurrence_type]
    return unless max

    if recurrence_interval > max
      errors.add(:recurrence_interval, "は#{max}以下で入力してください")
    end
  end
end
