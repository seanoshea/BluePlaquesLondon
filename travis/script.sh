#!/bin/sh
set -e

xcodebuild -workspace BluePlaquesLondon.xcworkspace -scheme BluePlaquesLondon -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO test
