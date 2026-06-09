FROM --platform=linux/amd64 ruby:2.1.10-slim

# 1. Update APT sources to use archive.debian.org since Jessie is EOL
RUN echo "deb http://archive.debian.org/debian/ jessie main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until && \
    echo 'Acquire::AllowInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99no-check-valid-until && \
    echo 'APT::Get::AllowUnauthenticated "true";' >> /etc/apt/apt.conf.d/99no-check-valid-until

# 2. Install dependencies
RUN apt-get update && apt-get install -y --force-yes --no-install-recommends \
    build-essential \
    libmysqlclient-dev \
    git \
    nodejs \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 3. Install Bundler 1.x (since Rails 4 supports Bundler < 2.0)
RUN gem install bundler -v '< 2.0' --no-rdoc --no-ri

# 4. Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# 5. Install gems
# Rewrite git:// URLs to https:// since GitHub disabled the git:// protocol
RUN git config --global url."https://github.com/".insteadOf git://github.com/ && \
    bundle install --full-index --without development test

# 6. Copy application code
COPY . .

# 8. Set up ports and entrypoint
EXPOSE 3000
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# 9. Start Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
