require 'digest/blake3'
require 'fileutils'
require 'securerandom'

class FileHandler
  def initialize(file, cache)
    @file = file
    @cache = cache
  end

  def save
    puts @file.inspect
    filename = @file[:filename]
    tempfile = @file[:tempfile]

    unique_id = SecureRandom.uuid
    hash_name = generate_hashed_link(unique_id)

    filepath = File.join(UPLOAD_DIR, unique_id)
    puts "Attempting to save file to: #{filepath}"

    begin
      File.open(filepath, 'wb') do |f|
        f.write(tempfile.read)
      end
      puts "File saved successfully"
      cache_metadata(hash_name, unique_id, filename)
      puts "Generated Hashed link: #{hash_name}"
      hash_name
    rescue => e
      puts "Failed to save file: #{e.message}"
      FileUtils.rm(filepath) if File.exist?(filepath)
      false
    end
  end

  private

  def generate_hashed_link(unique_id)
    Digest::Blake3.hexdigest(unique_id)
  end

  def cache_metadata(hash_name, unique_id, file_name)
    metadata = { file_name: file_name, unique_id: unique_id }
    @cache.set(hash_name, metadata)
    puts "Metadata cached: #{hash_name} -> #{metadata}"  # Debug log
  end
end
