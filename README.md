# TFDownLoad

[![CI Status](http://img.shields.io/travis/1005052145@qq.com/TFDownLoad.svg?style=flat)](https://travis-ci.org/1005052145@qq.com/TFDownLoad)
[![Version](https://img.shields.io/cocoapods/v/TFDownLoad.svg?style=flat)](http://cocoapods.org/pods/TFDownLoad)
[![License](https://img.shields.io/cocoapods/l/TFDownLoad.svg?style=flat)](http://cocoapods.org/pods/TFDownLoad)
[![Platform](https://img.shields.io/cocoapods/p/TFDownLoad.svg?style=flat)](http://cocoapods.org/pods/TFDownLoad)


使用的NSURLSessionDownloadTask进行的下载，包括复杂的下载流畅

1. Mp4
2. M3U8
3. 列表

其中M3U8又分为一下几种情况

1. 里边的小片段是正常的，可以下载的小mp4片段
2. 里边的小片段是相对路径，需要拼接外部的地址，才能正常访问的
3. 里边又包括几个小M3U8片段，需要递归进行下载的


...尽情期待

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

TFDownLoad is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TFDownLoad'
```

## Author

1005052145@qq.com, 1005052145@qq.com

## License

TFDownLoad is available under the MIT license. See the LICENSE file for more info.
