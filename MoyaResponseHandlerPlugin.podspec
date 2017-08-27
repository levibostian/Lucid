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
  s.summary          = 'Quick to configure Moya plugin to handle API responses for mobile app.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
When building iOS apps, you need to handle the response from an API call. Maybe the response was successful. Maybe it failed because the user's Internet connection is bad. Maybe the status code was a 403 error. Maybe Moya failed parsing the response body to JSON. No matter what the case is, writing the code to handle these responses require a lot of boilerplate. With the help of Moya making it easy to work with networking calls, this plugin makes it very quick and easy to configure how your app will handle Moya network call responses.
                       DESC

  s.homepage         = 'https://github.com/levibostian/MoyaResponseHandlerPlugin'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Levi Bostian' => 'levi.bostian@gmail.com' }
  s.source           = { :git => 'https://github.com/levibostian/MoyaResponseHandlerPlugin.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/levibostian'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MoyaResponseHandlerPlugin/Classes/**/*'
  s.dependency 'Moya/RxSwift', '~> 8.0.5'
end
