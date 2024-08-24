class HeadersMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    nonce = SecureRandom.base64

    Thread.current[:style_nonce] = nonce

    status, headers, response = @app.call(env)

    originating_ip = extract_ip(env)

    headers['Server'] = 'Anonymoose'
    headers['X-Frame-Options'] = 'DENY'
    headers['X-Content-Type-Options'] = 'nosniff'
    headers['X-XSS-Protection'] = '1; mode=block'
    headers['X-Originating-IP'] = originating_ip
    headers['Content-Security-Policy'] = csp_header(nonce)

    [status, headers, response]
  end

  private

  def extract_ip(env)
    if env['HTTP_CF_CONNECTING_IP']
      env['HTTP_CF_CONNECTING_IP']
    elsif env['HTTP_X_FORWARDED_FOR']
      env['HTTP_X_FORWARDED_FOR'].split(',').first.strip
    elsif env['HTTP_X_REAL_IP']
      env['HTTP_X_REAL_IP']
    else
      env['REMOTE_ADDR']
    end
  end

  def csp_header(nonce)
    "default-src 'self'; style-src 'self' https://cdn.jsdelivr.net https://fonts.googleapis.com 'nonce-#{nonce}'; script-src 'self' https://cdn.jsdelivr.net; img-src 'self' data:; font-src 'self' https://cdn.jsdelivr.net https://fonts.gstatic.com; object-src 'none'; frame-ancestors 'none'; base-uri 'self';"
  end
end
