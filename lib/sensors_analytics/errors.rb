module SensorsAnalytics
  # Sensors Analytics SDK 的异常
  # 使用 Sensors Analytics SDK 时，应该捕获 IllegalDataError、ConnectionError 和 ServerError。Debug 模式下，会抛出 DebugModeError 用于校验数据导入是否正确，线上运行时不需要捕获 DebugModeError
  class SensorsAnalyticsError < StandardError
  end

  # 输入数据格式错误，如 Distinct Id、Event Name、Property Keys 不符合命名规范，或 Property Values 不符合数据类型要求
  class IllegalDataError < SensorsAnalyticsError
  end

  # 网络连接错误
  class ConnectionError < SensorsAnalyticsError
  end

  # 服务器返回导入失败
  class ServerError < SensorsAnalyticsError
  end

  # Debug模式下各种异常
  class DebugModeError < SensorsAnalyticsError
  end

  # 错误的 server url
  class WrongServerUrlError < SensorsAnalyticsError
  end
end