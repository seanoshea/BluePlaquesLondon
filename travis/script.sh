#!/bin/sh
set -e

xcodebuild -workspace BluePlaquesLondon.xcworkspace -scheme BluePlaquesLondon -sdk iphonesimulator test
