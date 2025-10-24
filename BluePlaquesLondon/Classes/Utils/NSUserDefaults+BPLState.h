/*
 Copyright (c) 2014 - present Upwards Northwards Software Limited
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 3. All advertising materials mentioning features or use of this software
 must display the following acknowledgement:
 This product includes software developed by Upwards Northwards Software Limited.
 4. Neither the name of Upwards Northwards Software Limited nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY UPWARDS NORTHWARDS SOFTWARE LIMITED ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL UPWARDS NORTHWARDS SOFTWARE LIMITED BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <CoreLocation/CoreLocation.h>

/**
 * Category that adds app state persistence methods to NSUserDefaults.
 * Manages storage and retrieval of user preferences and app state data.
 */
@interface NSUserDefaults (BPLState)

/// Last known blue plaque coordinate that user viewed
@property (NS_NONATOMIC_IOSONLY, readonly) CLLocationCoordinate2D lastKnownBPLCoordinate;
/**
 * Saves the last known blue plaque coordinate.
 * @param coordinate The coordinate to save
 */
- (void)saveLastKnownBPLCoordinate:(CLLocationCoordinate2D)coordinate;

/// Last known user location coordinate
@property (NS_NONATOMIC_IOSONLY, readonly) CLLocationCoordinate2D lastKnownCoordinate;
/**
 * Saves the user's last known location coordinate.
 * @param coordinate The coordinate to save
 */
- (void)saveLastKnownCoordinate:(CLLocationCoordinate2D)coordinate;

/// Current map zoom level
@property (NS_NONATOMIC_IOSONLY, readonly) float mapZoom;
/**
 * Saves the current map zoom level.
 * @param zoom The zoom level to save
 */
- (void)saveMapZoom:(float)zoom;

/// Whether analytics tracking is enabled
@property (NS_NONATOMIC_IOSONLY, getter=isTrackingEnabled, readonly) BOOL trackingEnabled;
/**
 * Saves the tracking enabled preference.
 * @param trackingEnabled YES to enable tracking, NO to disable
 */
- (void)saveTrackingEnabled:(BOOL)trackingEnabled;

@end
