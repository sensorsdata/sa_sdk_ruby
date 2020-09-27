require 'base64'
require 'json'
require 'zlib'

module SensorsAnalytics
  class SensorsAnalyticsConsumer
    def initialize(server_url)
      @http_client = Http.new(server_url,
        keep_alive: ::SensorsAnalytics.conf.keep_alive)
    end

    def request!(event_list, headers = {})
      unless event_list.is_a?(Array) && headers.is_a?(Hash)
        raise IllegalDataError.new("The argument of 'request!' should be a Array.")
      end

      # GZip && Base64 encode
      wio = StringIO.new("w")
      gzip_io = Zlib::GzipWriter.new(wio)
      gzip_io.write(event_list.to_json)
      gzip_io.close
      data = Base64.encode64(wio.string).gsub("\n", '')
      form_data = {"data_list" => data, "gzip" => 1}

      @http_client.request(form_data, headers)
    end
  end

  # 实现逐条、同步发送的 Consumer，初始化参数为 Sensors Analytics 收集数据的 URI
  class DefaultConsumer < SensorsAnalyticsConsumer

    def initialize(server_url)
      super(server_url)
    end

    def send(event)
      event_list = [event]

      begin
        response_code, response_body = request!(event_list)
      rescue => e
        raise ConnectionError.new("Could not connect to Sensors Analytics, with error \"#{e.message}\".")
      end

      unless response_code.to_i == 200
        raise ServerError.new("Could not write to Sensors Analytics, server responded with #{response_code} returning: '#{response_body}'")
      end
    end

  end

  # 实现批量、同步发送的 Consumer，初始化参数为 Sensors Analytics 收集数据的 URI 和批量发送的缓存大小
  class BatchConsumer < SensorsAnalyticsConsumer

    MAX_FLUSH_BULK = 50

    def initialize(server_url, flush_bulk = MAX_FLUSH_BULK)
      @event_buffer = []
      @flush_bulk = [flush_bulk, MAX_FLUSH_BULK].min
      super(server_url)
    end

    def send(event)
      @event_buffer << event
      flush if @event_buffer.length >= @flush_bulk
    end

    def flush
      @event_buffer.each_slice(@flush_bulk) do |event_list|
        begin
          response_code, response_body = request!(event_list)
        rescue => e
          raise ConnectionError.new("Could not connect to Sensors Analytics, with error \"#{e.message}\".")
        end

        unless response_code.to_i == 200
          raise ServerError.new("Could not write to Sensors Analytics, server responded with #{response_code} returning: '#{response_body}'")
        end
      end
      @event_buffer = []
    end

  end

  # Debug 模式的 Consumer，Debug 模式的具体信息请参考文档
  #
  #     http://www.sensorsdata.cn/manual/debug_mode.html
  #
  # write_data 参数为 true，则 Debug 模式下导入的数据会导入 Sensors Analytics；否则，Debug 模式下导入的数据将只进行格式校验，不会导入 Sensors Analytics 中
  class DebugConsumer < SensorsAnalyticsConsumer

    def initialize(server_url, write_data)
      uri = URI.parse(server_url)
      # 将 URL Path 替换成 Debug 模式的 '/debug'
      uri.path = '/debug'

      @headers = {}
      unless write_data
        @headers['Dry-Run'] = 'true'
      end

      super(uri.to_s)
    end

    def send(event)
      event_list = [event]

      begin
        response_code, response_body = request!(event_list, @headers)
      rescue => e
        raise DebugModeError.new("Could not connect to Sensors Analytics, with error \"#{e.message}\".")
      end

      puts "=========================================================================="

      if response_code.to_i == 200
        puts "valid message: #{event_list.to_json}"
      else
        puts "invalid message: #{event_list.to_json}"
        puts "response code: #{response_code}"
        puts "response body: #{response_body}"
      end

      if response_code.to_i >= 300
        raise DebugModeError.new("Could not write to Sensors Analytics, server responded with #{response_code} returning: '#{response_body}'")
      end
    end

  end
end
