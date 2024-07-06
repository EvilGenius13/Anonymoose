require 'net/http'
require 'json'

class LoggingMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    context = RequestContext.new
    env['request_context'] = context
    start_time = Time.now

    status, headers, response = @app.call(env)
    duration = Time.now - start_time

    context.add_log_data(:method, env['REQUEST_METHOD'])
    context.add_log_data(:path, env['PATH_INFO'])
    context.add_log_data(:status, status)
    context.add_log_data(:duration, duration)
    context.add_log_data(:ip, env['REMOTE_ADDR'])

    log_request(context)

    [status, headers, response]
  end

  private

  def log_request(context)
    log_entry = context.to_h
    send_to_axiom(log_entry)
  end

  def send_to_axiom(log_entry)
    uri = URI("https://api.axiom.co/v1/datasets/#{ENV['AXIOM_DATASET']}/ingest")
    headers = {
      'Authorization' => "Bearer #{ENV['AXIOM_API_TOKEN']}",
      'Content-Type' => 'application/json'
    }
    body = [log_entry].to_json

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path, headers)
    request.body = body

    response = http.request(request)
    if response.is_a?(Net::HTTPSuccess)
      puts "Logged Request"
    else
      puts "Failed to send log to Axiom: #{response.code} - #{response.body}"
    end
  end
end
