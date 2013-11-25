#!/bin/sh

env

xcodebuild -list -workspace BluePlaquesLondon.xcworkspace

brew update
brew install xctool ios-sim
