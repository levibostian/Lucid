# Lucid
Make Moya errors more human readable. Show users of your app an error message they can understand. 

![Swift 4.0.x](https://img.shields.io/badge/Swift-4.0.x-orange.svg)

![](meta/header.jpg)

[![Version](https://img.shields.io/cocoapods/v/Lucid.svg?style=flat)](http://cocoapods.org/pods/Lucid)
[![License](https://img.shields.io/cocoapods/l/Lucid.svg?style=flat)](http://cocoapods.org/pods/Lucid)
[![Platform](https://img.shields.io/cocoapods/p/Lucid.svg?style=flat)](http://cocoapods.org/pods/Lucid)

# Why?

When using Moya, if your app ever encounters an error such as no Internet connection, Moya gives you an `error.localizedDescription` such as "Status code does not fall into range". I don't want to show that error message to my users. I would rather tell them, "You do not have an Internet connection. Please connect then try again.". This is where Lucid was born. 

# How? 

* Create a class that inherits the `LucidErrorMessageProvider` protocol. 

```swift
class MyLucidErrorMessageProvider: LucidErrorMessageProvider {
    ...
}
```

* Set this class as the default error handler for all of your Moya endpoints:

```swift 
LucidConfiguration.setDefaultErrorHandler(MyLucidErrorMessageProvider())
```

* Use your `MoyaProvider` as usual to call your endpoints. When an error is encountered, the `String` that your `LucidErrorMessageProvider` returns will be put into the `error.localizedDescription` so you can feel comfortable showing it to your users.

## Installation

Lucid is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Lucid"

// Or, use RxSwift version
pod "Lucid/RxSwift"
```

## Author 

* Levi Bostian - [GitHub](https://github.com/levibostian), [Twitter](https://twitter.com/levibostian), [Website/blog](http://levibostian.com)

![Levi Bostian image](https://gravatar.com/avatar/22355580305146b21508c74ff6b44bc5?s=250)

## License

Lucid is available under the MIT license. See the LICENSE file for more info.
 
## Docs

[Check out the docs here](http://cocoadocs.org/docsets/Lucid/0.3.0/). 

## Development 

### Documentation 

The docs are generated and hosted by cocoapods automatically for cocoadocs. 

The docs are generated via jazzy using command: `jazzy --podspec Lucid.podspec` (assuming jazzy is intalled. If not: `gem install jazzy`)

# Credits 

* Thank you to [Moya-ObjectMapper](https://github.com/ivanbruel/Moya-ObjectMapper) for the API design implementation for this project. 

* Photo by [Steve Richey](https://unsplash.com/photos/enTun1g_5b4?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
