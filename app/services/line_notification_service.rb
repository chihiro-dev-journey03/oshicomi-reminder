require "line/bot"

class LineNotificationService
  class SendError < StandardError; end

  def initialize
    @client = Line::Bot::Client.new do |config|
      config.channel_secret = ENV.fetch("LINE_MESSAGING_CHANNEL_SECRET")
      config.channel_token  = ENV.fetch("LINE_MESSAGING_CHANNEL_ACCESS_TOKEN")
    end
  end

  def send_reminder(reminder)
    user    = reminder.user
    book    = reminder.book
    message = build_message(book, reminder)

    response = @client.push_message(user.uid, message)

    unless response.is_a?(Net::HTTPSuccess)
      raise SendError, "LINE API error: #{response.code} #{response.body}"
    end

    true
  end

  private

  def build_message(book, reminder)
    text = "📚 リマインダー\n「#{book.title}」の読書タイムです！"
    text += "\n\nメモ: #{reminder.memo}" if reminder.memo.present?

    { type: "text", text: text }
  end
end
