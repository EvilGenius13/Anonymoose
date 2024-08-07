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

# Create necessary directories
RUN mkdir -p /app/uploads

# Copy the config directory to ensure puma.rb is included
COPY config /app/config

# Expose the port the app runs on
EXPOSE 9292

# Define environment variable
ENV RACK_ENV production

# Command to run the application
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
