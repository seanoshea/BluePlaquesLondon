platform :ios, '7.0'

xcodeproj 'BluePlaquesLondon.xcodeproj'

pod 'TTTAttributedLabel', '~> 1.6.3'
pod 'GoogleAnalytics-iOS-SDK', '~> 3.0'
pod 'Google-Maps-iOS-SDK', '~> 1.6.0'
pod 'IntentKit'
pod 'HCViews'
pod 'SVProgressHUD', :head
pod 'iRate'
pod 'iOS-KML-Framework', :git => 'https://github.com/FLCLjp/iOS-KML-Framework.git'

post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ARCHS'] = "$(ARCHS_STANDARD_INCLUDING_64_BIT)"
    end
  end
end
