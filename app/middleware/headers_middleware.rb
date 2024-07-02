class HeadersMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    originating_ip = extract_ip(env)
    
    headers['Server'] = 'Anonymoose'
    headers['X-Frame-Options'] = 'DENY'
    headers['X-Content-Type-Options'] = 'nosniff'
    headers['Content-Security-Policy'] = "default-src 'self'"
    headers['X-XSS-Protection'] = '1; mode=block'
    headers['X-Originating-IP'] = originating_ip
    headers['Content-Security-Policy'] = csp_header
    
    [status, headers, response]
  end

  private

  def extract_ip(env)
    if env['HTTP_X_FORWARDED_FOR']
      # If behind a proxy, take the first IP in the list
      env['HTTP_X_FORWARDED_FOR'].split(',').first.strip
    else
      # Otherwise, use the remote address
      env['REMOTE_ADDR']
    end
  end

  def csp_header
    nonce = SecureRandom.base64
    "default-src 'self'; style-src 'self' https://cdn.jsdelivr.net; script-src 'self' https://cdn.jsdelivr.net 'nonce-#{nonce}'; img-src 'self' data:; font-src 'self' https://cdn.jsdelivr.net; object-src 'none'; frame-ancestors 'none'; base-uri 'self';"
  end
end