class RequestContext
  attr_accessor :log_data

  def initialize
    @log_data = {
      timestamp: Time.now.iso8601,
      environment: ENVIRONMENT,
      method: nil,
      headers: nil,
      response: nil,
      path: nil,
      status: nil,
      duration: nil,
      ip: nil,
      file_extension: nil,
      file_size: nil,
    }

    # Dynamically define getter and setter methods for each log_data key
    @log_data.each_key do |key|
      define_singleton_method(key) do
        @log_data[key]
      end

      define_singleton_method("#{key}=") do |value|
        @log_data[key] = value
      end
    end
  end

  def add_log_data(key, value)
    @log_data[key] = value
  end

  def to_h
    @log_data
  end
end
