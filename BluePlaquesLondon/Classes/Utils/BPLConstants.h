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

@interface BPLConstants : NSObject

extern NSString * const BPLKMZFilename;
extern NSString * const BPLMapDetailViewControllerSegue;
extern NSString * const BPLWikipediaViewControllerSegue;
extern NSString * const BPLDetailChooserViewControllerSegue;
extern NSString * const BPLStreetMapViewControllerSegue;

#pragma mark - 3rd Party Keys

extern NSString * const BPLCrashReportingKey;
extern NSString * const BPLTrackingKey;
extern NSString * const BPLMapsKey;

#pragma mark - NSNotificationCenter Keys

extern NSString * const BPLNetworkAvailable;
extern NSString * const BPLDetailChooserViewControllerRowSelected;

#pragma mark - Tracking

extern NSString * const BPLApplicationLoaded;
extern NSString * const BPLUIActionCategory;
extern NSString * const BPLErrorCategory;
extern NSString * const BPLKMZFileParsing;
extern NSString * const BPLRateAppStoreOpened;

extern NSString * const BPLDetailsButtonPressedEvent;
extern NSString * const BPLWikipediaButtonPressedEvent;
extern NSString * const BPLStreetViewButtonPressedEvent;
extern NSString * const BPLDirectionsButtonPressedEvent;
extern NSString * const BPLTableRowPressedEvent;
extern NSString * const BPLMarkerPressedEvent;
extern NSString * const BPLMarkerInfoWindowPressedEvent;
extern NSString * const BPLAboutLinkPressedEvent;
extern NSString * const BPLWikipediaPageLoadErrorEvent;
extern NSString * const BPLStreetMapsPageLoadErrorEvent;
extern NSString * const BPLTweetSent;
extern NSString * const BPLKMZFileParsingEvent;
extern NSString * const BPLRateAppButtonPressedEvent;
extern NSString * const BPLDeclineRateAppButtonPressedEvent;
extern NSString * const BPLRemindRateAppButtonPressedEvent;
extern NSString * const BPLRateAppStoreOpenedEvent;

@end
