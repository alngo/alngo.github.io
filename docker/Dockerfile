FROM ruby:alpine3.15

RUN apk add build-base

RUN gem install bundler jekyll

WORKDIR /app

COPY ../Gemfile .

RUN bundle install

CMD bundle exec jekyll serve --host 0.0.0.0
