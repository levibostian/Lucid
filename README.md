# Lucid
Make [Moya](https://github.com/Moya/Moya) errors more human readable. Show users of your app an error message they can understand. 

![Swift 4.0.x](https://img.shields.io/badge/Swift-4.0.x-orange.svg)

![](meta/header.jpg)

[![Version](https://img.shields.io/cocoapods/v/Lucid.svg?style=flat)](http://cocoapods.org/pods/Lucid)
[![License](https://img.shields.io/cocoapods/l/Lucid.svg?style=flat)](http://cocoapods.org/pods/Lucid)
[![Platform](https://img.shields.io/cocoapods/p/Lucid.svg?style=flat)](http://cocoapods.org/pods/Lucid)

# Why?

When using Moya, if your app ever encounters an error such as no Internet connection, Moya gives you an `error.localizedDescription` such as "Status code does not fall into range". I don't want to show that error message to my users. I would rather tell them, "You do not have an Internet connection. Please connect then try again.". This is where Lucid was born. 

# How? 

* Create a class that inherits the `LucidErrorMessageProvider` protocol. This is the class that will be notified when an error has occurred and it will return error messages depending on the error that happened.

```swift
class MyLucidErrorMessageProvider: LucidErrorMessageProvider {
    ...
}
```

* Set this new class you created as the default error handler for all of your Moya endpoints:

```swift 
LucidConfiguration.setDefaultErrorHandler(MyLucidErrorMessageProvider())
```

* In your Moya error handler, get a Lucid error from that original error:

```swift
provider = MoyaProvider<GitHub>()
provider.request(.zen) { result in
    switch result {
    case let .success(moyaResponse):
        do {
            try! moyaResponse.filterSuccessfulStatusCodes()

            let data = moyaResponse.data
            let statusCode = moyaResponse.statusCode
            // do something with the response data or statusCode
        } catch (error: LucidMoyaError) {
            let humanReadableError = error.localizedDescription
        }
    case let .failure(error):
        let humanReadableError = error.getLucidError()

        // Feel confident showing `humanReadableError.localizedDescription` to your app users as the error message will actually be helpful to them. 

        // this means there was a network failure - either the request
        // wasn't sent (connectivity), or no response was received (server
        // timed out).  If the server responds with a 4xx or 5xx error, that
        // will be sent as a ".success"-ful response.
    }
}
```

You can use the extension `.getLucidError()` on any error returned from Moya, or you can use the set of `.filter(invalidStatusCodes: )` functions provided by Lucid on the Moya response to get a `LucidMoyaError`. Once you have a `LucidMoyaError`, you can be confident that your `.localizedDescription` is a human readable one that you provided and can be shown to a user. 

---

## RxSwift 

Lucid provides RxSwift functionality to make Lucid easier to work with. 

```
provider = MoyaProvider<GitHub>()
provider.rx
  .request(.userProfile("ashfurrow"))
  .filterSuccessfulStatusCodes() // Lucid, as well as Moya, provide functions to filter out status codes that are 'invalid' for your API. 
  .processErrors() // Will run `.getLucidError()` on an error if it is thrown in the stream. If you choose not to use this line, you can manually call `.getLucidError()` on the error returned from this function. 
  .subscribe { event in
    switch event {
    case let .success(response):
        image = UIImage(data: response.data)
    case let .error(error):
        let humanReadableError = error.localizedDescription
        // Because we used `.processErrors()` above, we can feel confident that our error message is human readable and will be helpful to our user. 
    }
}
```

## Installation

Lucid is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

**Note:** I recommend appending the version of the cocoapod to the Podfile line entry like: `pod "Lucid", '~> 0.4.0'` because this library at this time does *not* provide the guarantee of backwards compatibility. Be aware when using it the API can change at anytime. I don't want your code to break the next time you call `pod update` :). 

The latest version at this time is: [![Version](https://img.shields.io/cocoapods/v/Lucid.svg?style=flat)](http://cocoapods.org/pods/Lucid)

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
