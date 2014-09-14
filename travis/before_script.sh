#!/bin/sh

env

brew update
sudo easy_install cpp-coveralls

gem install cocoapods
pod install
