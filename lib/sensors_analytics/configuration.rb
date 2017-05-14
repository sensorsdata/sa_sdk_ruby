module SensorsAnalytics
  class Configuration
    attr_accessor :server_url, :keep_alive, :debug, :dry_run, :batch_size

    def initialize
      @server_url = nil
      @keep_alive = true
      @dry_run = false
      @debug = false
      @batch_size = 0
    end
  end

  class << self
    def conf
      @conf ||= Configuration.new
    end

    def config
      yield conf
      @client = nil
    end
  end
end
