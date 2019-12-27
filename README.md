# Sensors Analytics

This is the official Ruby SDK for Sensors Analytics.

## Easy Installation

You can get Sensors Analytics SDK using gem.
Add below to you `Gemfile`

```
  gem 'sensors_analytics_sdk'
```

Or execute `gem install` as below.

```
  gem install sensors_analytics_sdk
```

Once the SDK is successfully installed, use the Sensors Analytics SDK likes:

```ruby
  require 'sensors_analytics_sdk'

  SA_URL = 'http://sa_host.com:8006/sa?token=xxx'

  consumer = SensorsAnalytics::DefaultConsumer.new(SA_URL)
  sa = SensorsAnalytics::SensorsAnalytics.new(consumer)

  distinct_id = "ABCDEF123456"
  sa.track(distinct_id, "UserLogin", {"Source" : "HomePage"})
```

Http keepalive is supported now. Add gem `net-http-persistent` to your `Gemfile`. Then it will use http keepalive by default.

## To learn more

See our [full manual](http://www.sensorsdata.cn/manual/ruby_sdk.html)

## License

Copyright 2015－2020 Sensors Data Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

**同时，我们禁止一切基于神策数据开源 SDK 的商业活动！**

