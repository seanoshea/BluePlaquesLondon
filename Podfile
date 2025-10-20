platform :ios, '18.0'

source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_modular_headers!

project 'BluePlaquesLondon.xcodeproj'

target 'BluePlaquesLondon' do
  pod 'GoogleMaps'
  pod 'iOS-KML-Framework', '0.0.2'
  pod 'TBXML', :path => 'BluePlaquesLondon/Dependencies/TBXML'
  pod 'FirebaseAnalytics'

  pod 'GTMNSStringHTMLAdditions'

  target 'BluePlaquesLondonTests' do
    inherit! :search_paths

    pod 'OCMock', '~> 3.6.0'
    pod 'OHHTTPStubs', '~> 6.1.0'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.0'
      if target.name == 'iOS-KML-Framework'
        config.build_settings['HEADER_SEARCH_PATHS'] ||= []
        config.build_settings['HEADER_SEARCH_PATHS'] << '$(SRCROOT)/../BluePlaquesLondon/Dependencies/TBXML/TBXML-Headers'
      end
    end
  end
end
