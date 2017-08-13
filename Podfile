platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!

project 'BluePlaquesLondon.xcodeproj'

target 'BluePlaquesLondon' do
  pod 'TTTAttributedLabel', '2.0.0'
  pod 'GoogleAnalytics', '3.17.0'
  pod 'GoogleMaps', '1.13.2'
  pod 'IntentKit', '0.7.5'
  pod 'iRate', :git => 'https://github.com/nicklockwood/iRate.git', :branch => 'master'
  pod 'iOS-KML-Framework', :git => 'https://github.com/FLCLjp/iOS-KML-Framework.git'
  pod 'GTMNSStringHTMLAdditions', '0.2.1'
  pod 'MaterialComponents/Typography', '31.0.1'
  pod 'MaterialComponents/Buttons', '31.0.1'
  pod 'MaterialComponents/FlexibleHeader', '31.0.1'
  pod 'MaterialComponents/Collections', '31.0.1'
  pod 'MaterialComponents/CollectionCells', '31.0.1'
  pod 'MaterialComponents/ActivityIndicator', '31.0.1'

  target 'BluePlaquesLondonTests' do
    inherit! :search_paths

    pod 'OCMock', '~> 3.4'
    pod 'OHHTTPStubs', '~> 6.0.0'
  end
end
