FROM ruby:2.6.3
 
# mysqlとの連携のために必要なものをインストール
# rmはキャッシュを削除し、イメージのデータ量を削減するため
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y mysql-client --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
 
WORKDIR /usr/src/app
 
# bundle updateで使うためにコンテナ内に２つのファイルをコピー
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
 
RUN gem install bundler \
  && bundle install --path vendor/bundle