class RequestContext
  attr_accessor :log_data

  def initialize
    @log_data = {
      timestamp: Time.now.iso8601,
      environment: ENVIRONMENT,
      method: nil,
      path: nil,
      status: nil,
      duration: nil,
      ip: nil,
      file_extension: nil,
      file_size: nil,
    }
  end

  def add_log_data(key, value)
    @log_data[key] = value
  end

  def to_h
    @log_data
  end
end
