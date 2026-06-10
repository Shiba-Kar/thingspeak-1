FROM ruby:3.2.4-slim

# 1. Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    git \
    nodejs \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Copy Gemfile and shim
COPY Gemfile ruby3_shim.rb ./

# 3. Set up Ruby 3 compatibility shim
ENV RUBYOPT="-r/app/ruby3_shim.rb"

# 4. Install Bundler 1.x (since Rails 4 supports Bundler < 2.0)
RUN gem install bundler -v '< 2.0' --no-document

# 5. Install gems
RUN git config --global url."https://github.com/".insteadOf git://github.com/ && \
    bundle _1.17.3_ install --without development test

# 6. Copy application code
COPY . .

# 8. Set up ports and entrypoint
EXPOSE 3000
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# 9. Start Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
