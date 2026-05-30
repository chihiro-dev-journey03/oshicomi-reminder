# whenever による cron 設定ファイル
# cron への反映: bundle exec whenever --update-crontab
# cron の確認:  bundle exec whenever
# cron の削除:  bundle exec whenever --clear-crontab

set :output, "log/cron.log"
set :environment, ENV.fetch("RAILS_ENV", "production")

# 毎日 00:05 に当日分のリマインダー通知ジョブをスケジュールする
every 1.day, at: "12:05 am" do
  rake "reminders:schedule_today"
end
