FROM ruby:alpine3.15
RUN apk add build-base && \
    gem install bundler jekyll
WORKDIR /jekyll
COPY ./Gemfile .
RUN bundle install
CMD bundle exec jekyll serve
