require 'aws-sdk-s3'

module S3Connection
  @client = nil
  @bucket_name = ENV['S3_BUCKET'] || 'development-bucket'

  def self.client
    Aws::S3::Client.new(
      endpoint: ENV['S3_ENDPOINT'] || 'http://localhost:9000',
      region: ENV['S3_REGION'] || 'us-east-1',
      access_key_id: ENV['S3_ACCESS_KEY_ID'] || 'development',
      secret_access_key: ENV['S3_SECRET_ACCESS_KEY'] || 'development',
      force_path_style: true,
    )
  end

  def self.bucket_name
    @bucket_name
  end

  def self.reset_client
    @client = nil
  end

  private

  def self.create_bucket_unless_exists
    unless bucket_exists?
      client.create_bucket(bucket: @bucket_name)
      puts "Bucket #{@bucket_name} created."
    end
  end

  def self.bucket_exists?
    client.head_bucket(bucket: @bucket_name)
    true
  rescue Aws::S3::Errors::NotFound
    false
  end
end