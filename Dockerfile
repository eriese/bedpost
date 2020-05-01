FROM ruby:2.5.8-slim-buster

RUN apt-get update \
    && apt-get install -y \
    nodejs npm

RUN npm install -g yarn
RUN gem install rails
RUN gem install bundler

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN yarn
RUN bundle install

ENTRYPOINT ["foreman", "start"]
