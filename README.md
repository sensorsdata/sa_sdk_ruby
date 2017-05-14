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

  SensorsAnalytics.config do |conf|
    conf.server_url = 'http://sa_host.com:8006/sa?token=xxx' # sa server url
    #conf.keep_alive = true # use http persistent. need net-http-persistent gem
    #conf.debug = false     # use debug
    #conf.dry_run = false   # dry run
    #conf.batch_size = 0    # flush in batch
  end

  SensorsAnalytics.track("ABCDEF123456", "UserLogin", {"Source" : "HomePage"})
```

Http keepalive is supported now. Add gem `net-http-persistent` to your `Gemfile`. Then it will use http keepalive by default.

## To learn more

See our [full manual](http://www.sensorsdata.cn/manual/ruby_sdk.html)

