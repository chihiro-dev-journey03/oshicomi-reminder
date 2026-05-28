require "net/http"
require "json"

class LineNotificationService
  class SendError < StandardError; end

  LINE_PUSH_URL = "https://api.line.me/v2/bot/message/push"

  def send_reminder(reminder)
    user = reminder.user
    book = reminder.book

    body = {
      to: user.uid,
      messages: [ { type: "text", text: build_message_text(book, reminder) } ]
    }.to_json

    response = post_to_line(body)

    unless response.is_a?(Net::HTTPSuccess)
      raise SendError, "LINE API error: #{response.code} #{response.body}"
    end

    true
  end

  private

  def post_to_line(body)
    uri  = URI(LINE_PUSH_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"]  = "application/json"
    request["Authorization"] = "Bearer #{ENV.fetch('LINE_MESSAGING_CHANNEL_ACCESS_TOKEN')}"
    request.body = body

    http.request(request)
  end

  def build_message_text(book, reminder)
    text = "🔔「#{book.title}」の更新日です！"
    text += "\n\nメモ: #{reminder.memo}" if reminder.memo.present?
    text
  end
end
