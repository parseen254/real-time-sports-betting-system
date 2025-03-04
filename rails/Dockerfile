FROM ruby:3.2.2
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y node.js
RUN npm install -g yarn
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]