namespace :reminders do
  desc "現在の15分枠で送信すべきリマインダーをメール通知する（ユーザーごとにグルーピングして1通送信）"
  task send_due: :environment do
    result = Reminders::SendDueService.new.call
    puts "sent=#{result[:sent]} failed=#{result[:failed]}"
  end
end
