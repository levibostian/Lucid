#
# Be sure to run `pod lib lint MoyaResponseHandlerPlugin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MoyaResponseHandlerPlugin'
  s.version          = '0.2.0'
  s.summary          = 'Parse Moya networking errors for a more human readable error message to show to the end user.'
  s.description      = <<-DESC
When building iOS apps, you need to handle the response from an API call. Maybe the response was successful. Maybe it failed because the user's Internet connection is bad. Maybe the status code was a 403 error. Maybe Moya failed parsing the response body to JSON. No matter what the case is, writing the code to handle these responses require a lot of boilerplate. With the help of Moya making it easy to work with networking calls, this plugin makes it very quick and easy to configure how your app will handle Moya network call responses.
                       DESC

  s.homepage         = 'https://github.com/levibostian/MoyaResponseHandlerPlugin'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Levi Bostian' => 'levi.bostian@gmail.com' }
  s.source           = { :git => 'https://github.com/levibostian/MoyaResponseHandlerPlugin.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/levibostian'
  s.ios.deployment_target = '8.0'
  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files  = "Source/Core/*.swift"
    ss.dependency "Moya", '~> 8.0.5'
    ss.framework  = "Foundation"
  end

  s.subspec "RxSwift" do |ss|
    ss.source_files = "Source/RxSwift/*.swift"
    ss.dependency "Moya/RxSwift", '~> 8.0.5'
    ss.dependency "MoyaResponseHandlerPlugin/Core"
  end
end
