require 'dalli'

class CachingMiddleware
  def initialize(app)
    @app = app
    @cache = Dalli::Client.new(MEMCACHED_ADDRESS, username: MEMCACHED_USERNAME, password: MEMCACHED_PASSWORD)
  end

  def call(env)
    env['cache'] = self
    @app.call(env)
  end

  def set(key, value, ttl = 0)
    @cache.set(key, value, ttl)
  end

  def get(key)
    @cache.get(key)
  end
end
