# Blue Plaques London
iOS Application for finding Blue Plaques through London. [App Store Link](http://www.appstore.com/seanoshea)

[![CI Status](https://github.com/seanoshea/BluePlaquesLondon/workflows/CI/badge.svg)](https://github.com/seanoshea/BluePlaquesLondon/actions/workflows/ci.yml)
[![Code Coverage](http://codecov.io/github/seanoshea/BluePlaquesLondon/coverage.svg?branch=develop)](http://codecov.io/github/seanoshea/BluePlaquesLondon?branch=develop)
[![PRs Welcome](https://img.shields.io/badge/prs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
[![License](http://img.shields.io/badge/license-BSD-green.svg?style=flat)](https://github.com/seanoshea/BluePlaquesLondon/blob/master/LICENSE)
[![Languages](https://img.shields.io/github/languages/count/seanoshea/BluePlaquesLondon)](https://img.shields.io/github/languages/count/seanoshea/BluePlaquesLondon)
[![Top Language](https://img.shields.io/github/languages/top/seanoshea/BluePlaquesLondon)](https://img.shields.io/github/languages/top/seanoshea/BluePlaquesLondon)
[![Open Issues](https://img.shields.io/github/issues/seanoshea/BluePlaquesLondon)](https://img.shields.io/github/issues/seanoshea/BluePlaquesLondon)
[![Closed Issues](https://img.shields.io/github/issues-closed/seanoshea/BluePlaquesLondon)](https://img.shields.io/github/issues-closed/seanoshea/BluePlaquesLondon)
[![Twitter: @seanoshea](https://img.shields.io/badge/contact-@seanoshea-blue.svg?style=flat)](https://twitter.com/seanoshea)

# Requirements
- **Ruby**: 3.4.7 or later
- **iOS**: 18.0 or later
- **Xcode**: 16.0 or later
- **CocoaPods**: Latest version

# Development Setup
1. Install Ruby 3.4.7 (using rbenv, rvm, or your preferred Ruby version manager)
2. Clone the repository
3. Run `bundle install` to install Ruby dependencies
4. Run `pod install` to install iOS dependencies
5. Open `BluePlaquesLondon.xcworkspace` in Xcode

# Building and Testing
- **Run tests**: `bundle exec fastlane test`
- **Build for development**: `bundle exec fastlane build`
- **Deploy to TestFlight**: `bundle exec fastlane beta`
- **Deploy to App Store**: `bundle exec fastlane release`

# Contributing
Suggestions and bug reports for the application are always welcome. Open an issue on github if you'd like to see an addition to the application or if you spot a bug. Pull requests are especially welcome (and most likely to get merged if you have some unit tests associated with the merge request).

# Android Version
An Android version of the application is available in Google's [Play Store](http://play.google.com/store/apps/details?id=com.upwardsnorthwards.blueplaqueslondon). The source code for that version of the application is available [here](http://github.com/seanoshea/BluePlaquesLondon-Android).

# Beta Builds
If you're interested in access to beta-builds of the application, send an email to oshea.ie@gmail.com