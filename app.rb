require 'sinatra/base'
require 'sinatra/content_for'
require_relative 'config/environment'
require_relative 'app/handlers/file_handler'
require_relative 'app/middleware/caching_middleware'
require_relative 'app/middleware/headers_middleware'
require_relative 'app/middleware/logging_middleware'
require_relative 'app/middleware/request_context'

MAX_UPLOAD_SIZE = 5 * 1024 * 1024  # 5 MB

class Anonymoose < Sinatra::Base
  helpers Sinatra::ContentFor

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  use LoggingMiddleware
  use CachingMiddleware
  use HeadersMiddleware

  get '/' do
    erb :index
  end

  get '/upload' do
    erb :upload
  end

  post '/upload' do
    ttl = params[:expiration].to_i
    file = params[:file]
    context = env['request_context']
  
    if file.nil?
      @error_message = 'No file received'
      return erb :upload
    end
  
    file_size = file[:tempfile].size
    if file_size > MAX_UPLOAD_SIZE
      @error_message = "File size exceeds the maximum limit of #{MAX_UPLOAD_SIZE / 1024 / 1024} MB"
      return erb :upload
    end
  
    if file
      # Throttle upload speed to 50 KB/s
      throttle_speed_kbps = 50
      chunk_size = 1024 # 1 KB
      tempfile = file[:tempfile]
      
      File.open(tempfile.path, 'rb') do |file|
        while chunk = file.read(chunk_size)
          sleep(chunk_size.to_f / (throttle_speed_kbps * 1024)) # Sleep to throttle speed
        end
      end
      
      file_handler = FileHandler.new(file, env['cache'], ttl)
      hashed_link = file_handler.save
  
      context.add_log_data(:file_size, file_size)
      context.add_log_data(:file_extension, File.extname(file[:filename]))
  
      if hashed_link
        erb :upload_success, locals: { link: hashed_link }
      else
        puts "File upload failed"
        @error_message = "File upload failed. Please upload a valid file."
        erb :upload
      end
    else
      puts "No file received"
      @error_message = "No file received"
      erb :upload
    end
  end

  get '/uploads/:hash' do
    hash = params[:hash]
    context = env['request_context']
    metadata = env['cache'].get(hash)

    if metadata
      unique_id = metadata[:unique_id]
      original_name = metadata[:file_name]

      context.add_log_data(:file_hash, hash)

      begin
        file_data = download_from_s3(unique_id)
        if file_data
          content_type 'application/octet-stream'
          attachment original_name
          response.write file_data
        else
          status 500
          @error_message = "File could not be downloaded."
          erb :error
        end
      rescue => e
        puts "Error sending file: #{e.message}"
        status 500
        @error_message = "File could not be downloaded."
        erb :error
      end
    else
      status 404
      erb :error
    end
  end

  not_found do
    erb :error
  end

  private

  def download_from_s3(unique_id)
    s3_handler = S3Handler.new
    begin
      resp = s3_handler.download_file(unique_id)
      file_data = resp.body.read

      # Debugging: Check the first few bytes of the file data
      puts "File content preview: #{file_data[0, 100].inspect}"

      file_data
    rescue => e
      puts "Error downloading file from S3: #{e.message}"
      nil
    end
  end
end