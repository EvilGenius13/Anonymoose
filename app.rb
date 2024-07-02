require 'sinatra/base'
require 'sinatra/content_for'
require 'falcon'
require_relative 'app/config/environment'
require_relative 'app/handlers/file_handler'
require_relative 'app/middleware/caching_middleware'
require_relative 'app/middleware/headers_middleware'

MAX_UPLOAD_SIZE = 5 * 1024 * 1024  # 5 MB

class Anonymoose < Sinatra::Base
  helpers Sinatra::ContentFor

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

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
      # puts "Received file upload request: #{file.inspect}"
      file_handler = FileHandler.new(file, env['cache'], ttl)
      hashed_link = file_handler.save
      if hashed_link
        # puts "File upload successful, hashed link: #{hashed_link}"
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
    metadata = env['cache'].get(hash)
    if metadata
      unique_id = metadata[:unique_id]
      original_name = metadata[:file_name]
      # puts "Unique ID: #{unique_id}, Original name: #{original_name}"  # Debug log
      filepath = File.join(UPLOAD_DIR, unique_id)
      # Need error handling here I believe
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
