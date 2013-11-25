#!/bin/sh
set -e

xctool -workspace BluePlaquesLondon.xcworkspace -scheme BluePlaquesLondon -sdk iphonesimulator build
