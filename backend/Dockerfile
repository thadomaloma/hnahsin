# syntax=docker/dockerfile:1
FROM ruby:3.3.6-slim AS build
WORKDIR /rails
RUN apt-get update -qq && apt-get install --no-install-recommends -y build-essential libpq-dev git && rm -rf /var/lib/apt/lists/*
COPY Gemfile ./
RUN bundle install
COPY . .
RUN bundle exec bootsnap precompile app/ lib/

FROM ruby:3.3.6-slim
WORKDIR /rails
RUN apt-get update -qq && apt-get install --no-install-recommends -y libpq5 curl && rm -rf /var/lib/apt/lists/*
COPY --from=build /usr/local/bundle /usr/local/bundle
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
COPY --from=build --chown=rails:rails /rails /rails
RUN mkdir -p log tmp/pids storage && chown -R rails:rails log tmp storage
ENV RAILS_ENV=production RAILS_LOG_TO_STDOUT=true RAILS_SERVE_STATIC_FILES=true
EXPOSE 3000
USER 1000:1000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
