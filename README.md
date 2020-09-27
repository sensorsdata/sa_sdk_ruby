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

## 讨论

| 扫码加入神策数据开源社区 QQ 群<br>群号：785122381 | 扫码加入神策数据开源社区微信群 |
| ------ | ------ |
|![ QQ 讨论群](https://opensource.sensorsdata.cn/wp-content/uploads/ContentCommonPic_1.png) | ![ 微信讨论群 ](https://opensource.sensorsdata.cn/wp-content/uploads/ContentCommonPic_2.png) |

## 公众号

| 扫码关注<br>神策数据开源社区 | 扫码关注<br>神策数据开源社区服务号 |
| ------ | ------ |
|![ 微信订阅号 ](https://opensource.sensorsdata.cn/wp-content/uploads/ContentCommonPic_3.png) | ![ 微信服务号 ](https://opensource.sensorsdata.cn/wp-content/uploads/ContentCommonPic_4.png) |

## 新书推荐

| 《数据驱动：从方法到实践》 | 《Android 全埋点解决方案》 | 《iOS 全埋点解决方案》
| ------ | ------ | ------ |
| [![《数据驱动：从方法到实践》](https://opensource.sensorsdata.cn/wp-content/uploads/data_driven_book_1.jpg)](https://item.jd.com/12322322.html) | [![《Android 全埋点解决方案》](https://opensource.sensorsdata.cn/wp-content/uploads/Android-全埋点thumbnail_1.png)](https://item.jd.com/12574672.html) | [![《iOS 全埋点解决方案》](https://opensource.sensorsdata.cn/wp-content/uploads/iOS-全埋点thumbnail_1.png)](https://item.jd.com/12867068.html)

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

