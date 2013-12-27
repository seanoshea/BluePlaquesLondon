platform :ios, '7.0'

xcodeproj 'BluePlaquesLondon.xcodeproj'

pod 'TTTAttributedLabel', '~> 1.6.3'
pod 'CocoaLumberjack', '~> 1.6.2'
pod 'GoogleAnalytics-iOS-SDK', '~> 3.0'
pod 'Google-Maps-iOS-SDK', '~> 1.6.0'
pod 'DACircularProgress', '~> 2.1.0'
pod 'IntentKit'
pod 'HCViews'

post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ARCHS'] = "$(ARCHS_STANDARD_INCLUDING_64_BIT)"
    end
  end
end