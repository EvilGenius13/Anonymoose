# Dockerfile
# Stage 1: Build
FROM ruby:3.2.2 AS builder

# Set working directory
WORKDIR /app

# Install Rust and dependencies required for blake3-rb
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gcc \
    g++ \
    libclang-dev \
    libssl-dev \
    libffi-dev \
    make \
    && rm -rf /var/lib/apt/lists/* \
    && curl https://sh.rustup.rs -sSf | sh -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install dependencies
RUN gem install bundler && bundle install

# Copy the rest of the application code
COPY . .

# Stage 2: Production
FROM ruby:3.2.2-slim

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libmemcached-dev \
    libssl-dev \
    libffi-dev \
    make \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy application code and installed gems from build stage
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Ensure bundler is available in the production stage
RUN gem install bundler

# Copy the config directory to grab puma configuration
COPY config /app/config

# Copy the entrypoint script
COPY app/scripts/entrypoint.sh /app/entrypoint.sh

# Make sure the entrypoint script has execute permission
RUN chmod +x /app/entrypoint.sh

# Expose the port the app runs on
EXPOSE 9292

# Set the entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]
