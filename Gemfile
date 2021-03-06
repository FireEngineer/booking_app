source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
# Use postgresql as the database for Active Record
gem 'mysql2'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3', group: :development
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "jquery-rails"
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'mini_racer'
# for authentication
gem 'devise', '4.5.0'
gem 'devise-i18n'
gem 'devise-i18n-views'

# to load environment variables from `.env`.
gem 'dotenv-rails'

# link google calendar
gem 'google-api-client', require: 'google/apis/calendar_v3'

# to Use sidekiq
gem 'redis-namespace'
gem 'sidekiq'

gem 'kaminari', '~> 0.17.0'
gem 'kaminari-bootstrap', '~> 3.0.1'
gem 'rails-i18n', '~> 5.1' # For 5.0.x, 5.1.x and 5.2.x

gem 'bootstrap', '~> 4.1.1'
gem 'jquery-rails'
gem 'active_decorator'

# 決済機能
gem 'payjp'

# full_calendar
gem 'momentjs-rails'
gem 'fullcalendar-rails'

# line_bot
gem 'line-bot-api'
# idデコード用
gem 'jwt'

# 検索機能
gem 'ransack'

# 環境変数設定用
gem 'dotenv-rails'

# cronの設定
gem 'whenever', require: false

# 論理削除
gem 'paranoia', '~> 2.3', '>= 2.3.1'

# ランダムな文字列を生成して、URLにする
gem 'public_uid'

# userデバイスを判定
gem 'browser'

# リンクを生成する
gem 'rinku'

# PWA対応
gem 'serviceworker-rails'

# for image uploader with AWS S3
gem 'carrierwave'
gem 'fog'

# text_areaのフォームを自動調整
gem 'autosize', '~> 2.4'

gem 'thin'

# エラーをスラックに通知
gem 'slack_500'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.6'
  gem 'spring-commands-rspec'
  gem "factory_bot_rails"
  gem 'rails-controller-testing'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem "rails-erd"
  # N+1問題の改善
  gem 'bullet'
  gem 'rubocop', require: false
  gem 'brakeman', :require => false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'webdrivers', '~> 3.0'
  gem "rspec_junit_formatter"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
