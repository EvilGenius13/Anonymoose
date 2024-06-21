require 'sinatra/base'
require 'falcon'
require_relative 'app/config/environment'
require_relative 'app/handlers/file_handler'
require_relative 'app/middleware/caching_middleware'
require_relative 'app/middleware/headers_middleware'

class Anonymoose < Sinatra::Base
  use CachingMiddleware
  use HeadersMiddleware

  get '/' do
    erb :index
  end

  get '/upload' do
    erb :upload
  end

  post '/upload' do
    file = params[:file]
    if file
      puts "Received file upload request: #{file.inspect}"
      file_handler = FileHandler.new(file, env['cache'])
      hashed_link = file_handler.save
      if hashed_link
        puts "File upload successful, hashed link: #{hashed_link}"
        erb :upload_success, locals: { link: hashed_link }
      else
        puts "File upload failed"
        "File upload failed. Please upload a valid file."
      end
    else
      puts "No file received"
      "No file received"
    end
  end

  get '/uploads/:hash' do
    hash = params[:hash]
    metadata = env['cache'].get(hash)
    if metadata
      unique_id = metadata[:unique_id]
      original_name = metadata[:file_name]
      puts "Unique ID: #{unique_id}, Original name: #{original_name}"  # Debug log
      filepath = File.join(UPLOAD_DIR, unique_id)
      if File.exist?(filepath)
        send_file filepath, disposition: 'attachment', filename: original_name, type: 'application/octet-stream'
      else
        halt 404, 'File not found'
      end
    else
      halt 404, 'File not found'
    end
  end
end
