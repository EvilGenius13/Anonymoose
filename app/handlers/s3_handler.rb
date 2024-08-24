require 'aws-sdk-s3'

class S3Handler
  def initialize
    @client = Aws::S3::Client.new(
      endpoint: ENV['S3_ENDPOINT'] || 'http://localhost:9000',
      region: ENV['S3_REGION'] || 'us-east-1',
      access_key_id: ENV['S3_ACCESS_KEY_ID'] || 'development',
      secret_access_key: ENV['S3_SECRET_ACCESS_KEY'] || 'development',
      force_path_style: true,
    )
    @bucket = ENV['S3_BUCKET'] || 'development-bucket'
    create_bucket_unless_exists
  end

  def upload_file(tempfile, unique_id, ttl)
    expiration_date = Time.now.utc + ttl
    @client.put_object(
      bucket: @bucket,
      key: unique_id,
      body: tempfile,
      metadata: {
        'x-amz-meta-expiration' => expiration_date.iso8601
      },
      object_lock_mode: 'GOVERNANCE',
      object_lock_retain_until_date: expiration_date.iso8601
    )

  rescue => e
    puts "Error uploading file to S3: #{e.message}"
    raise
  end

  def download_file(unique_id)
    @client.get_object(bucket: @bucket, key: unique_id)
  rescue => e
    puts "Error downloading file from S3: #{e.message}"
    raise
  end

  private

  def create_bucket_unless_exists
    unless bucket_exists?
      @client.create_bucket(
        bucket: @bucket,
        object_lock_enabled_for_bucket: true
      )
      puts "Bucket #{@bucket} with object lock created."
    end
  rescue Aws::S3::Errors::BucketAlreadyExists, Aws::S3::Errors::BucketAlreadyOwnedByYou
    puts "Bucket #{@bucket} already exists."
  end

  def bucket_exists?
    @client.head_bucket(bucket: @bucket)
    true
  rescue Aws::S3::Errors::NotFound
    false
  end
end
