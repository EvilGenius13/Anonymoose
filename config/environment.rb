require 'dotenv/load'

MEMCACHED_ADDRESS = ENV['MEMCACHED_ADDRESS'] || 'localhost:11211'
MEMCACHED_USERNAME = ENV['MEMCACHED_USERNAME']
MEMCACHED_PASSWORD = ENV['MEMCACHED_PASSWORD']
ENVIRONMENT = ENV['RACK_ENV'] || 'development'
AXIOM_DATASET = ENV['AXIOM_DATASET']
AXIOM_API_TOKEN = ENV['AXIOM_API_TOKEN']
S3_ENDPOINT = ENV['S3_ENDPOINT'] || 'http://localhost:9000'
S3_REGION = ENV['S3_REGION'] || 'us-east-1'
S3_ACCESS_KEY_ID = ENV['S3_ACCESS_KEY']
S3_SECRET_ACCESS = ENV['S3_SECRET_ACCESS']
S3_BUCKET = ENV['S3_BUCKET'] || 'development-bucket'