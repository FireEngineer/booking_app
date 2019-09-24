require File.expand_path(File.dirname(__FILE__) + "/environment")
# cronを実行する環境変数
rails_env = ENV['RAILS_ENV'] || :development
# cronを実行する環境変数をセット
set :environment, rails_env
# cronのログの吐き出し場所
set :output, "#{Rails.root}/log/cron.log"

env :PATH, ENV['PATH']

if rails_env.to_sym != :development
    # リマインダーの送信タスク
    every 1.day, :at => '9:00 pm' do
        rake "task_reminder:push"
    end

    # リマインダーのテスト配信タスク
    every 1.day, :at => '8:42 pm' do
        rake "task_reminder:test"
    end

    # スタッフシストの自動作成タスク
    every 1.month, :at => '03:00 am' do
        rake "staff_shifts:create"
    end

end
