FROM ruby:alpine3.15

RUN apk add build-base
RUN gem install bundler
RUN gem install jekyll

RUN mkdir /app
WORKDIR /app
COPY . .
RUN bundle install

CMD ["bundle", "exec", "jekyll", "serve"]
