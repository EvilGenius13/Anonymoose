require 'minitest/autorun'
require_relative '../../app/handlers/file_handler'
require 'dalli'
require 'aws-sdk-s3'
require 'fileutils'
require 'securerandom'

class FileHandlerTest < Minitest::Test
  def setup
    @cache = Dalli::Client.new('localhost:11211', username: ENV['MEMCACHED_USERNAME'], password: ENV['MEMCACHED_PASSWORD'])
    @file = { filename: 'test.txt', tempfile: Tempfile.new('test.txt') }
    @file[:tempfile].write('test content')
    @file[:tempfile].rewind

    @s3_client = Aws::S3::Client.new(
      endpoint: ENV['S3_ENDPOINT'] || 'http://localhost:9000',
      region: ENV['S3_REGION'] || 'us-east-1',
      access_key_id: ENV['S3_ACCESS_KEY_ID'] || 'development',
      secret_access_key: ENV['S3_SECRET_ACCESS_KEY'] || 'development',
      force_path_style: true
    )
    @bucket = ENV['S3_BUCKET'] || 'development-bucket'
    create_bucket_unless_exists
  end

  def teardown
    @file[:tempfile].close
    @file[:tempfile].unlink
    clear_bucket
    @cache.flush_all
    sleep(1)
  end

  def test_file_save_and_cache
    ttl = :t2  # 15 seconds TTL
    file_handler = FileHandler.new(@file, @cache, ttl)
    hash_name = file_handler.save

    assert hash_name, "Hash name should be generated"

    metadata = @cache.get(hash_name)
    unique_id = metadata[:unique_id] if metadata

    sleep 5 # Temp fix for CI

    # Check if file is saved in MinIO
    object_exists = s3_object_exists?(unique_id)
    assert object_exists, "File should be saved in MinIO"

    # Check if metadata is cached
    assert metadata, "Metadata should be cached"
    assert_equal 'test.txt', metadata[:file_name], "File name should match"
  end

  def test_ttl_expiration
    ttl = :t1  # 2 seconds TTL
    file_handler = FileHandler.new(@file, @cache, ttl)
    hash_name = file_handler.save

    sleep(5)  # Wait for TTL to expire

    metadata = @cache.get(hash_name)
    assert_nil metadata, "Metadata should expire and be nil"
  end

  private

  def create_bucket_unless_exists
    @s3_client.create_bucket(bucket: @bucket) unless bucket_exists?
  rescue Aws::S3::Errors::BucketAlreadyOwnedByYou, Aws::S3::Errors::BucketAlreadyExists
    # Bucket already exists, no action needed
  end

  def bucket_exists?
    @s3_client.head_bucket(bucket: @bucket)
    true
  rescue Aws::S3::Errors::NotFound
    false
  end

  def clear_bucket
    objects = @s3_client.list_objects_v2(bucket: @bucket).contents
    objects.each do |obj|
      @s3_client.delete_object(bucket: @bucket, key: obj.key)
    end
  end

  def s3_object_exists?(key)
    @s3_client.head_object(bucket: @bucket, key: key)
    true
  rescue Aws::S3::Errors::NotFound
    false
  end
end
