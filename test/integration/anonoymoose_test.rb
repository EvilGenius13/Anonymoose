require 'minitest/autorun'
require 'rack/test'
require 'aws-sdk-s3'
require_relative '../../app'

class AnonymooseTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Anonymoose.new
  end

  def setup
    @s3_client = Aws::S3::Client.new(
      endpoint: ENV['S3_ENDPOINT'] || 'http://localhost:9000',
      region: ENV['S3_REGION'] || 'us-east-1',
      access_key_id: ENV['S3_ACCESS_KEY_ID'] || 'development',
      secret_access_key: ENV['S3_SECRET_ACCESS_KEY'] || 'development',
      force_path_style: true
    )
    @bucket = ENV['S3_BUCKET'] || 'test-bucket'
    create_bucket_unless_exists
    # Create a test file
    File.open('test/test.txt', 'w') { |file| file.write("test content") }
  end

  def teardown
    File.delete('test/test.txt') if File.exist?('test/test.txt')
    clear_bucket
  end

  def test_home_page
    get '/'
    assert last_response.ok?
    assert_includes last_response.body, 'Welcome to Anonymoose'
  end

  def test_upload_page
    get '/upload'
    assert last_response.ok?
    assert_includes last_response.body, 'Upload a File'
  end

  def test_file_upload
    file = Rack::Test::UploadedFile.new('test/test.txt', 'text/plain')
    post '/upload', { file: file, expiration: 1 }

    assert last_response.ok?
    assert_includes last_response.body, 'Upload Success'
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
end
