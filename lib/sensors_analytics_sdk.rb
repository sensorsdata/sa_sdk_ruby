
require 'sensors_analytics/version'
require 'sensors_analytics/configuration'
require 'sensors_analytics/errors'
require 'sensors_analytics/http'
require 'sensors_analytics/consumers'
require 'sensors_analytics/client'

module SensorsAnalytics
  API = [:track, :track_signup, :profile_set, :profile_set_once,
    :profile_increment, :profile_append, :profile_unset]

  class << self
    # 定义接口
    API.each do |api_name|
      define_method(api_name) do |*args|
        default_client.send(api_name, *args)
      end
    end

    def default_client
      @client ||= setup_client
    end

    private

    def setup_client
      if !conf.server_url || conf.server_url == ''
        raise WrongServerUrlError.new("server_url must be set")
      end

      consumer = if conf.debug
        DebugConsumer.new(conf.server_url, !conf.dry_run)
      elsif conf.batch_size > 0
        BatchConsumer.new(conf.server_url, conf.batch_size)
      else
        DefaultConsumer.new(conf.server_url)
      end
      ::SensorsAnalytics::SensorsAnalytics.new(consumer)
    end
  end
end
