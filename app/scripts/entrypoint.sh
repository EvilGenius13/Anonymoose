#!/bin/sh

# Check the value of the SERVER environment variable
if [ "$SERVER" = "falcon" ]; then
  echo "Starting Falcon server..."
  bundle exec falcon serve --count 2 --bind http://0.0.0.0:9292
else
  echo "Starting Puma server..."
  bundle exec puma -C config/puma.rb
fi