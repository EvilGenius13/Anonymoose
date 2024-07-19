require 'digest/blake3'
require 'securerandom'
require_relative 's3_handler'

class FileHandler
  def initialize(file, cache, ttl = 0)
    @file = file
    @cache = cache
    @ttl = ttl
    @s3_handler = S3Handler.new
  end

  def save
    filename = @file[:filename]
    tempfile = @file[:tempfile]

    unique_id = SecureRandom.uuid
    hash_name = generate_hashed_link(unique_id)

    puts "Generated unique_id: #{unique_id}"  # Debugging
    puts "Generated hash_name: #{hash_name}"  # Debugging

    begin
      @s3_handler.upload_file(tempfile, unique_id)
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
