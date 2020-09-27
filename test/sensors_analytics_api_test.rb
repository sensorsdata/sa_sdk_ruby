require 'test_helper'

SensorsAnalytics.config do |conf|
  conf.server_url = 'http://sa_host.com:8006/sa?token=xxx'
  conf.debug = true
end

class SensorsAnalyticsApiTest < Minitest::Test

  def test_track
    SensorsAnalytics::Http.any_instance.expects(:request).returns([200, "ok"])

    SensorsAnalytics.track("abcdefg", "test_event",
      "age" => 26,
      "$time" => Time.now,
      "event_time" => Time.now)
  end

  def test_profile_set
    SensorsAnalytics::Http.any_instance.expects(:request).returns([200, "ok"])

    SensorsAnalytics.profile_set("abcdefg", {age: 24, sex: "male"})
  end
end
