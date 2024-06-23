require 'minitest/autorun'
require_relative '../../app/handlers/file_handler'
require 'dalli'
require 'fileutils'
require 'securerandom'

class FileHandlerTest < Minitest::Test
  UPLOAD_DIR = 'uploads'  # Ensure this matches your actual upload directory

  def setup
    @cache = Dalli::Client.new('localhost:11211', username: ENV['MEMCACHED_USERNAME'], password: ENV['MEMCACHED_PASSWORD'])
    @file = { filename: 'test.txt', tempfile: Tempfile.new('test.txt') }
    @file[:tempfile].write('test content')
    @file[:tempfile].rewind
    FileUtils.mkdir_p(UPLOAD_DIR)
  end

  def teardown
    @file[:tempfile].close
    @file[:tempfile].unlink
    FileUtils.rm_rf(UPLOAD_DIR)
    @cache.flush_all  # Clear cache after each test
  end

  def test_file_save_and_cache
    ttl = 5  # 5 seconds TTL
    file_handler = FileHandler.new(@file, @cache, ttl)
    hash_name = file_handler.save

    assert hash_name, "Hash name should be generated"

    # Check if file is saved
    metadata = @cache.get(hash_name)
    assert metadata, "Metadata should be cached"
    assert_equal 'test.txt', metadata[:file_name], "File name should match"
  end

  def test_ttl_expiration
    ttl = 1  # 1 second TTL
    file_handler = FileHandler.new(@file, @cache, ttl)
    hash_name = file_handler.save

    sleep(ttl + 2)  # Wait for TTL to expire

    metadata = @cache.get(hash_name)
    assert_nil metadata, "Metadata should expire and be nil"
  end
end
