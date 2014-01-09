/*
 Copyright 2013 - 2014 Sean O' Shea
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "BPLConstants.h"

@implementation BPLConstants

NSString * const BPLKMZFilename = @"blueplaques";
NSString * const BPLMapDetailViewControllerSegue = @"BPLMapDetailViewControllerSegue";
NSString * const BPLWikipediaViewControllerSegue = @"BPLWikipediaViewControllerSegue";
NSString * const BPLDetailChooserViewControllerSegue = @"BPLDetailChooserViewControllerSegue";
NSString * const BPLStreetMapViewControllerSegue = @"BPLStreetMapViewControllerSegue";

#pragma mark - 3rd Party Keys

NSString * const BPLCrashReportingKey = @"8aa2986353e21d6181e23a9360cd528dca68aafb";
NSString * const BPLTrackingKey = @"UA-46153093-1";
NSString * const BPLMapsKey = @"AIzaSyD3VT-JDnPAKhNiStoUpVAxOyIUUrWUsz0";

#pragma mark - NSNotificationCenter Keys

NSString * const BPLNetworkAvailable = @"BPLNetworkAvailable";
NSString * const BPLDetailChooserViewControllerRowSelected = @"BPLDetailChooserViewControllerRowSelected";

#pragma mark - Tracking

NSString * const BPLApplicationLoaded = @"ApplicationLoaded";
NSString * const BPLUIActionCategory = @"BPLUIActionCategory";
NSString * const BPLErrorCategory = @"BPLErrorCategory";
NSString * const BPLKMZFileParsing = @"BPLKMZFileParsing";

NSString * const BPLDetailsButtonPressedEvent = @"BPLDetailsButtonPressedEvent";
NSString * const BPLWikipediaButtonPressedEvent = @"BPLWikipediaButtonPressedEvent";
NSString * const BPLStreetViewButtonPressedEvent = @"BPLStreetViewButtonPressedEvent";
NSString * const BPLDirectionsButtonPressedEvent = @"BPLDirectionsButtonPressedEvent";
NSString * const BPLTableRowPressedEvent = @"BPLTableRowPressedEvent";
NSString * const BPLMarkerPressedEvent = @"BPLMarkerPressedEvent";
NSString * const BPLMarkerInfoWindowPressedEvent = @"BPLMarkerInfoWindowPressedEvent";
NSString * const BPLAboutLinkPressedEvent = @"BPLAboutLinkPressedEvent";
NSString * const BPLWikipediaPageLoadErrorEvent = @"BPLWikipediaPageLoadErrorEvent";
NSString * const BPLStreetMapsPageLoadErrorEvent = @"BPLStreetMapsPageLoadErrorEvent";
NSString * const BPLKMZFileParsingEvent = @"BPLKMZFileParsingEvent";

@end
