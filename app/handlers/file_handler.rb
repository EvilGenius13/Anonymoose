require 'digest/blake3'
require 'securerandom'
require_relative 's3_handler'

class FileHandler
  TTL = {
    1 => 900, # 15 minutes
    2 => 3600, # 1 hour
    3 => 14400, # 4 hours
    4 => 28800, # 8 hours
    5 => 86400, # 1 day
  }.freeze

  def initialize(file, cache, ttl = 0)
    @file = file
    @cache = cache
    @ttl = TTL[ttl] || TTL[1]
    @s3_handler = S3Handler.new
  end

  def save
    filename = @file[:filename]
    tempfile = @file[:tempfile]

    unique_id = SecureRandom.uuid
    hash_name = generate_hashed_link(unique_id)

    begin
      @s3_handler.upload_file(tempfile, unique_id, @ttl)
      cache_metadata(hash_name, unique_id, filename)
      hash_name
    rescue => e
      puts "Failed to save file: #{e.message}"
      false
    ensure
      tempfile.close
      tempfile.unlink
    end
  end

  private

  def generate_hashed_link(unique_id)
    Digest::Blake3.hexdigest(unique_id)
  end

  def cache_metadata(hash_name, unique_id, file_name)
    metadata = { file_name: file_name, unique_id: unique_id }
    @cache.set(hash_name, metadata, @ttl)
  end
end
