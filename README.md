# Lucid
Make Moya errors more human readable. Show users of your app an error message they can understand. 

![](meta/header.jpg)

[![Version](https://img.shields.io/cocoapods/v/Lucid.svg?style=flat)](http://cocoapods.org/pods/Lucid)
[![License](https://img.shields.io/cocoapods/l/Lucid.svg?style=flat)](http://cocoapods.org/pods/Lucid)
[![Platform](https://img.shields.io/cocoapods/p/Lucid.svg?style=flat)](http://cocoapods.org/pods/Lucid)

# Why?

When I build mobile apps, this is how I want to handle API network requests:

Was the API request successful (HTTP response status code >=200, <300)? 
* Yes
  * Parse the response to JSON, string, image, etc. Use the response on my app. 
* No
  * Was it a network connectivity issue? 
  * Yes
    * Show the user a human readable message saying they have no Internet, request failed but they can try again, etc. 
  * No
    * Was the network request successful, but the server responded back with a status code >=300?
    * Yes
      * Let me see the status code, possibly parse the response body, then return a human readable message to the user telling them about the error and how they can fix it. 
    * No
      * Was the error a Moya error such as an error parsing the respone body? 
      * Yes 
        * Handle however you wish. I want to log this error as it's probably an error with the app. Then, return human reable message to the user.
      * No 
        * The error is unknown. Handle however you wish. I want to log this error as it's probably an error with the app. Then, return human reable message to the user.

With all of the mobile apps I build and maintain, I copy/pasted this boilerplate code into each app and edited the code minimally to conform to the app I was building. This boilerplate code was hard to maintain across multiple apps, was a hard API to remember, error prone if I ever messed up a use case, and ugly. Because of this, I built this [Moya](https://github.com/Moya/Moya) plugin to allow me to have a quick, flexible, no boilerplate code solution for each of my apps. 

# How? 

* Create a class that inherits the `LucidMoyaResponseErrorProtocol` protocol. 

```swift
class MyLucidMoyaResponseErrorProtocol: LucidMoyaResponseErrorProtocol {
    ...
}
```

* Set this class as the default error handler for all of your Moya endpoints:

```swift 
LucidConfiguration.setDefaultErrorHandler(MyLucidMoyaResponseErrorProtocol())
```

* Use your `MoyaProvider` as usual to call your endpoints. 

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
