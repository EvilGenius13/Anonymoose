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
      file_handler = FileHandler.new(file, env['cache'], ttl)
      hashed_link = file_handler.save

      context.add_log_data(:file_size, file_size)
      context.add_log_data(:file_extension, File.extname(file[:filename]))

      if hashed_link
        erb :upload_success, locals: { link: hashed_link, ttl: ttl / 60 }
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
      filepath = File.join(UPLOAD_DIR, unique_id)

      context.add_log_data(:file_hash, hash)

      if File.exist?(filepath)
        send_file filepath, disposition: 'attachment', filename: original_name, type: 'application/octet-stream'
      else
        status 404
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
end
