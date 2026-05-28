require "line/bot"

class LineNotificationService
  class SendError < StandardError; end

  def initialize
    http_client = Line::Bot::V2::MessagingApi::ApiClient.new(
      channel_access_token: ENV.fetch("LINE_MESSAGING_CHANNEL_ACCESS_TOKEN")
    )
    @api = Line::Bot::V2::MessagingApi::MessagingApiApi.new(http_client)
  end

  def send_reminder(reminder)
    user    = reminder.user
    book    = reminder.book

    request = Line::Bot::V2::MessagingApi::PushMessageRequest.new(
      to: user.uid,
      messages: [ build_message(book, reminder) ]
    )

    @api.push_message(push_message_request: request)
    true
  rescue Line::Bot::V2::ApiError => e
    raise SendError, "LINE API error: #{e.code} #{e.message}"
  end

  private

  def build_message(book, reminder)
    text = "📚 リマインダー\n「#{book.title}」の読書タイムです！"
    text += "\n\nメモ: #{reminder.memo}" if reminder.memo.present?

    Line::Bot::V2::MessagingApi::TextMessage.new(text: text)
  end
end
