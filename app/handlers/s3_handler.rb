require_relative 's3_connection'

class S3Handler
  def initialize
    @client = S3Connection.client
    @bucket = S3Connection.bucket_name
  end

  def upload_file(tempfile, unique_id, ttl)
    expiration_date = Time.now.utc + ttl
    @client.put_object(
      bucket: @bucket,
      key: unique_id,
      body: tempfile,
      metadata: {
        'x-amz-meta-expiration' => expiration_date.iso8601
      }
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
end
