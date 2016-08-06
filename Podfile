platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!

project 'BluePlaquesLondon.xcodeproj'

target 'BluePlaquesLondon' do
  pod 'TTTAttributedLabel', '2.0.0'
  pod 'GoogleAnalytics', '3.14.0'
  pod 'GoogleMaps', '2.0.1'
  pod 'IntentKit', '0.7.2'
  pod 'HCViews', '1.3.1'
  pod 'SVProgressHUD', '2.0.3'
  pod 'iRate', :git => 'https://github.com/nicklockwood/iRate.git', :branch => 'master'
  pod 'iOS-KML-Framework', :git => 'https://github.com/FLCLjp/iOS-KML-Framework.git'
  pod 'GTMNSStringHTMLAdditions', '0.2.1'

  target 'BluePlaquesLondonTests' do
    inherit! :search_paths

    pod 'OCMock', '~> 3.3.1'
    pod 'OHHTTPStubs', '~> 5.1.0'
  end
end
