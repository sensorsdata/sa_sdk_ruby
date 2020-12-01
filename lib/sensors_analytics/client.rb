module SensorsAnalytics
  KEY_PATTERN = /^((?!^distinct_id$|^original_id$|^time$|^properties$|^id$|^first_id$|^second_id$|^users$|^events$|^event$|^user_id$|^date$|^datetime$)[a-zA-Z_$][a-zA-Z\d_$]{0,99})$/

  # Sensors Analytics SDK
  #
  # 通过 Sensors Analytics SDK 的构造方法及参数 Consumer 初始化对象，并通过 track, trackSignUp, profileSet 等方法向 Sensors Analytics 发送数据，例如
  #
  #     consumer = SensorsAnalytics::DefaultConsumer.new(SENSORS_ANALYTICS_URL)
  #     sa = SensorsAnalytics::SensorsAnalytics.new(consumer)
  #     sa.track("abcdefg", "ServerStart", {"sex" => "female"})
  #
  # SENSORS_ANALYTICS_URL 是 Sensors Analytics 收集数据的 URI，可以从配置界面中获得。
  #
  # Sensors Analytics SDK 通过 Consumer 向 Sensors Analytics 发送数据，提供三种 Consumer:
  #
  #     DefaultConsumer - 逐条同步发送数据
  #     BatchConsumer - 批量同步发送数据
  #     DebugModeConsumer - Debug 模式，用于校验数据导入是否正确
  #
  # Consumer 的具体信息请参看对应注释
  class SensorsAnalytics

    # Sensors Analytics SDK 构造函数，传入 Consumer 对象
    def initialize(consumer)
      @consumer = consumer
      # 初始化事件公共属性
      clear_super_properties
    end

    # 设置每个事件都带有的一些公共属性
    #
    # 当 track 的 Properties 和 Super Properties 有相同的 key 时，将采用 track 的
    def register_super_properties(properties)
      properties.each do |key, value|
        @super_properties[key] = value
      end
    end

    # 删除所有已设置的事件公共属性
    def clear_super_properties
      @super_properties = {
        '$lib' => 'Ruby',
        '$lib_version' => VERSION,
      }
    end

    # 记录一个的事件，其中 distinct_id 为触发事件的用户ID，event_name 标示事件名称，properties 是一个哈希表，其中每对元素描述事件的一个属性，哈希表的 Key 必须为 String 类型，哈希表的 Value 可以为 Integer、Float、String、TrueClass 和 FalseClass 类型
    def track(distinct_id, event_name, properties={})
      _track_event(:track, distinct_id, distinct_id, event_name, properties)
    end

    # 记录注册行为，其中 distinct_id 为注册后的用户ID，origin_distinct_id 为注册前的临时ID，properties 是一个哈希表，其中每对元素描述事件的一个属性，哈希表的 Key 必须为 String 类型，哈希表的 Value 可以为 Integer、Float、String、TrueClass 和 FalseClass 类型
    #
    # 这个接口是一个较为复杂的功能，请在使用前先阅读相关说明:
    #
    #     http://www.sensorsdata.cn/manual/track_signup.html
    #
    # 并在必要时联系我们的技术支持人员。
    def track_signup(distinct_id, origin_distinct_id, properties={})
      _track_event(:track_signup, distinct_id, origin_distinct_id, :$SignUp, properties)
    end

    # 设置用户的一个或多个属性，properties 是一个哈希表，其中每对元素描述用户的一个属性，哈希表的 Key 必须为 String 类型，哈希表的 Value 可以为 Integer、Float、String、Time、TrueClass 和 FalseClass 类型
    #
    # 无论用户该属性值是否存在，都将用 properties 中的属性覆盖原有设置
    def profile_set(distinct_id, properties)
      _track_event(:profile_set, distinct_id, distinct_id, nil, properties)
    end

    # 尝试设置用户的一个或多个属性，properties 是一个哈希表，其中每对元素描述用户的一个属性，哈希表的 Key 必须为 String 类型，哈希表的 Value 可以为 Integer、Float、String、Time、TrueClass 和 FalseClass 类型
    #
    # 若用户不存在该属性，则设置用户的属性，否则放弃
    def profile_set_once(distinct_id, properties)
      _track_event(:profile_set_once, distinct_id, distinct_id, nil, properties)
    end

    # 为用户的一个或多个属性累加一个数值，properties 是一个哈希表，其中每对元素描述用户的一个属性，哈希表的 Key 必须为 String 类型，Value 必须为 Integer 类型
    #
    # 若该属性不存在，则创建它并设置默认值为0
    def profile_increment(distinct_id, properties)
      _track_event(:profile_increment, distinct_id, distinct_id, nil, properties)
    end

    # 追加数据至用户的一个或多个列表类型的属性，properties 是一个哈希表，其中每对元素描述用户的一个属性，哈希表的 Key 必须为 String 类型，Value 必须为元素是 String 类型的数组
    #
    # 若该属性不存在，则创建一个空数组，并插入 properties 中的属性值
    def profile_append(distinct_id, properties)
      _track_event(:profile_append, distinct_id, distinct_id, nil, properties)
    end

    # 删除用户一个或多个属性，properties 是一个数组，其中每个元素描述一个需要删除的属性的 Key
    def profile_unset(distinct_id, properties)
      unless properties.is_a?(Array)
        IllegalDataError.new("Properties of PROFILE UNSET must be an instance of Array<String>.")
      end
      property_hash = {}
      properties.each do |key|
        property_hash[key] = true
      end
      _track_event(:profile_unset, distinct_id, distinct_id, nil, property_hash)
    end

    # 上报 item 数据
    def item_set(item_type, item_id, properties)
      _track_item(:item_set, item_type, item_id, properties)
    end

    # 删除 item 数据
    def item_delete(item_type, item_id)
      _track_item(:item_delete, item_type, item_id, {})
    end

    private

    def _track_event(event_type, distinct_id, origin_distinct_id, event_name, properties)
      _assert_key(:DistinctId, distinct_id)
      _assert_key(:OriginalDistinctId, origin_distinct_id)
      if event_type == :track
        _assert_key_with_regex(:EventName, event_name)
      end
      _assert_properties(event_type, properties)

      # 从事件属性中获取时间配置
      event_time = _extract_time_from_properties(properties)
      properties.delete(:$time)
      properties.delete("$time")

      event_properties = {}
      if event_type == :track || event_type == :track_signup
        event_properties = @super_properties.dup
      end

      properties.each do |key, value|
        if value.is_a?(Time)
          event_properties[key] = value.strftime("%Y-%m-%d %H:%M:%S.#{(value.to_f * 1000.0).to_i % 1000}")
        else
          event_properties[key] = value
        end
      end

      lib_properties = _get_lib_properties

      # Track / TrackSignup / ProfileSet / ProfileSetOne / ProfileIncrement / ProfileAppend / ProfileUnset
      event = {
        type: event_type,
        time: event_time,
        distinct_id: distinct_id,
        properties: event_properties,
        lib: lib_properties,
      }

      if event_type == :track
        # Track
        event[:event] = event_name
      elsif event_type == :track_signup
        # TrackSignUp
        event[:event] = event_name
        event[:original_id] = origin_distinct_id
      end

      @consumer.send(event)
    end

    def _track_item(event_type, item_type, item_id, properties)
      _assert_key_with_regex(:item_type, item_type)
      _assert_key(:item_id, item_id)

      if event_type == :item_set
        _assert_properties(event_type, properties)
      end

      # 从事件属性中获取时间配置
      event_time = _extract_time_from_properties(properties)
      properties.delete(:$time)
      properties.delete("$time")

      lib_properties = _get_lib_properties

      # event_type 有 item_set 和 item_delete 两种
      event = {
        type: event_type,
        time: event_time,
        item_id: item_id,
        item_type: item_type,
        lib: lib_properties,
      }

      if event_type == :item_set
        # item_set 有 properties 属性
        item_properties = {}

        properties.each do |key, value|
          if value.is_a?(Time)
            item_properties[key] = value.strftime("%Y-%m-%d %H:%M:%S.#{(value.to_f * 1000.0).to_i % 1000}")
          else
            item_properties[key] = value
          end
        end

        event[:properties] = item_properties
      end

      @consumer.send(event)
    end

    def _extract_time_from_properties(properties)
      properties.each do |key, value|
        if (key == :$time || key == "$time") && value.is_a?(Time)
          return (value.to_f * 1000).to_i
        end
      end
      return (Time.now.to_f * 1000).to_i
    end

    def _get_lib_properties
      @lib_properties ||= begin
        lib_properties = {
          '$lib' => 'Ruby',
          '$lib_version' => VERSION,
          '$lib_method' => 'code',
        }

        @super_properties.each do |key, value|
          if key == :$app_version || key == "$app_version"
            lib_properties[:$app_version] = value
          end
        end

        #lib_properties[:$lib_detail] = _get_lib_detail

        lib_properties
      end
    end

    def _get_lib_detail
      begin
        raise Exception
      rescue Exception => e
        trace = e.backtrace[3].split(':')
        file = trace[0]
        line = trace[1]
        function = trace[2].split('`')[1][0..-2]
        return "###{function}###{file}###{line}"
      end
    end

    def _assert_key(type, key)
      unless key.instance_of?(String) || key.instance_of?(Symbol)
        raise IllegalDataError.new("#{type} must be an instance of String / Symbol.")
      end
      unless key.length >= 1
        raise IllegalDataError.new("#{type} is empty.")
      end
      unless key.length <= 255
        raise IllegalDataError.new("#{type} is too long, max length is 255.")
      end
    end

    def _assert_key_with_regex(type, key)
      _assert_key(type, key)
      unless key =~ KEY_PATTERN
        raise IllegalDataError.new("#{type} '#{key}' is invalid.")
      end
    end

    def _assert_properties(event_type, properties)
      unless properties.instance_of?(Hash)
        raise IllegalDataError.new("Properties must be an instance of Hash.")
      end
      properties.each do |key, value|
        _assert_key_with_regex(:PropertyKey, key)

        unless value.is_a?(Integer) || value.is_a?(Float) || value.is_a?(String) || value.is_a?(Symbol) || value.is_a?(Array) || value.is_a?(TrueClass) || value.is_a?(FalseClass) || value.is_a?(Time)
          raise IllegalDataError.new("The properties value must be an instance of Integer/Float/String/Array.")
        end

        # 属性为 Array 时，元素必须为 String 或 Symbol 类型
        if value.is_a?(Array)
          value.each do |element|
            unless element.is_a?(String) || element.is_a?(Symbol)
              raise IllegalDataError.new("The properties value of PROFILE APPEND must be an instance of Array[String].")
            end
            # 元素的长度不能超过8192
            unless element.length <= 8192
              raise IllegalDataError.new("The properties value is too long.")
            end
          end
        end

        # 属性为 String 或 Symbol 时，长度不能超过8191
        if value.is_a?(String) || value.is_a?(Symbol)
          unless value.length <= 8192
            raise IllegalDataError.new("The properties value is too long.")
          end
        end

        # profile_increment 的属性必须为数值类型
        if event_type == :profile_increment
          unless value.is_a?(Integer)
            raise IllegalDataError.new("The properties value of PROFILE INCREMENT must be an instance of Integer.")
          end
        end

        # profile_append 的属性必须为数组类型，且数组元素必须为字符串
        if event_type == :profile_append
          unless value.is_a?(Array)
            raise IllegalDataError.new("The properties value of PROFILE APPEND must be an instance of Array[String].")
          end
          value.each do |element|
            unless element.is_a?(String) || element.is_a?(Symbol)
              raise IllegalDataError.new("The properties value of PROFILE APPEND must be an instance of Array[String].")
            end
          end
        end
      end
    end

  end
end
