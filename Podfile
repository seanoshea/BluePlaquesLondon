platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!

project 'BluePlaquesLondon.xcodeproj'

target 'BluePlaquesLondon' do
  pod 'TTTAttributedLabel', '2.0.0'
  pod 'GoogleAnalytics', '3.14.0'
  pod 'GoogleMaps', '1.13.2'
  pod 'IntentKit', '0.7.3'
  pod 'SVProgressHUD', '2.0.3'
  pod 'iRate', :git => 'https://github.com/nicklockwood/iRate.git', :branch => 'master'
  pod 'iOS-KML-Framework', :git => 'https://github.com/FLCLjp/iOS-KML-Framework.git'
  pod 'GTMNSStringHTMLAdditions', '0.2.1'
  pod 'MaterialComponents', :path => '../material-components-ios'
 
  target 'BluePlaquesLondonTests' do
    inherit! :search_paths

    pod 'OCMock', '~> 3.3.1'
    pod 'OHHTTPStubs', '~> 5.1.0'
  end
end
