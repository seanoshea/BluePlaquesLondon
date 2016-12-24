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
  pod 'MaterialComponents/Typography', '19.0.4'
  pod 'MaterialComponents/Buttons', '19.0.4'
  pod 'MaterialComponents/FlexibleHeader', '19.0.4'
  pod 'MaterialComponents/Collections', '19.0.4'
  pod 'MaterialComponents/CollectionCells', '19.0.4'
  pod 'MaterialComponents/ActivityIndicator', '19.0.4'

  target 'BluePlaquesLondonTests' do
    inherit! :search_paths

    pod 'OCMock', '~> 3.3.1'
    pod 'OHHTTPStubs', '~> 5.2.3'
  end
end
