workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup "config.ru"
port        ENV['PORT']     || 9292
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for connecting to services (e.g., Memcached, S3)
end
