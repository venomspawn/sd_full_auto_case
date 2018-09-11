FROM repo.it2.vm/ruby2.4.4-alpine3.7-logic

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .
