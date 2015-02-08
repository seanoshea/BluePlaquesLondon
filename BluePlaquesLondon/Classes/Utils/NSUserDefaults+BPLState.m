/*
 Copyright (c) 2014 - 2015 Upwards Northwards Software Limited
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

#import "NSUserDefaults+BPLState.h"

#import <GoogleMaps/GoogleMaps.h>

static NSString *const BPLStateLastKnownBPLCoordinatLatitude = @"BPLStateLastKnownBPLCoordinatLatitude";
static NSString *const BPLStateLastKnownBPLCoordinatLongitude = @"BPLStateLastKnownBPLCoordinatLongitude";
static NSString *const BPLStateLastKnownCoordinatLatitude = @"BPLStateLastKnownCoordinatLatitude";
static NSString *const BPLStateLastKnownCoordinatLongitude = @"BPLStateLastKnownCoordinatLongitude";

static NSString *const BPLStateMapZoom = @"BPLStateMapZoom";
static float const BPLStateMapZoomDefault = 15.0f;

static NSString *const BPLTrackingEnabled = @"BPLTrackingEnabled";

// Winston Churchill's lat/long
static CGFloat const BPLDefaultLatitude = 51.50016999993306f;
static CGFloat const BPLDefaultLongitude = -0.1814680000049975f;

@implementation NSUserDefaults (BPLState)

- (CLLocationCoordinate2D)lastKnownBPLCoordinate
{
    return [self savedCoordinateAtLatitudeKey:BPLStateLastKnownBPLCoordinatLatitude longitudeKey:BPLStateLastKnownBPLCoordinatLongitude];
}

- (void)saveLastKnownBPLCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self saveCoordinate:coordinate latitudeKey:BPLStateLastKnownBPLCoordinatLatitude longitudeKey:BPLStateLastKnownBPLCoordinatLongitude];
}

- (CLLocationCoordinate2D)lastKnownCoordinate
{
    return [self savedCoordinateAtLatitudeKey:BPLStateLastKnownCoordinatLatitude longitudeKey:BPLStateLastKnownCoordinatLongitude];
}

- (void)saveLastKnownCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self saveCoordinate:coordinate latitudeKey:BPLStateLastKnownCoordinatLatitude longitudeKey:BPLStateLastKnownCoordinatLongitude];
}

- (float)mapZoom
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    float mapZoom = [userDefaults floatForKey:BPLStateMapZoom];
    // ensure that we always have a positive zoom for the camera
    if (mapZoom <= 0.0f) {
        mapZoom = BPLStateMapZoomDefault;
    }
    return mapZoom;
}

- (void)saveMapZoom:(float)zoom
{
    NSParameterAssert(zoom > kGMSMinZoomLevel);
    NSParameterAssert(zoom < kGMSMaxZoomLevel);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:zoom forKey:BPLStateMapZoom];
    [userDefaults synchronize];
}

- (BOOL)isTrackingEnabled
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:BPLTrackingEnabled] == nil) {
        [self saveTrackingEnabled:YES];
    }
    return [userDefaults boolForKey:BPLTrackingEnabled];
}

- (void)saveTrackingEnabled:(BOOL)trackingEnabled
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:trackingEnabled forKey:BPLTrackingEnabled];
    [userDefaults synchronize];
}

- (CLLocationCoordinate2D)savedCoordinateAtLatitudeKey:(NSString *)latitudeKey longitudeKey:(NSString *)longitudeKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    CLLocationDegrees latitudeDegrees = [userDefaults doubleForKey:latitudeKey];
    CLLocationDegrees longitudeDegrees = [userDefaults doubleForKey:longitudeKey];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitudeDegrees, longitudeDegrees);
    // check to see whether this is a valid lat/long coordinate.
    if (![self isValidCoordinate:coordinate]) {
        coordinate = CLLocationCoordinate2DMake(BPLDefaultLatitude, BPLDefaultLongitude);
    }
    return coordinate;
}

- (void)saveCoordinate:(CLLocationCoordinate2D)coordinate latitudeKey:(NSString *)latitudeKey longitudeKey:(NSString *)longitudeKey
{
    if ([self isValidCoordinate:coordinate]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setDouble:coordinate.latitude forKey:latitudeKey];
        [userDefaults setDouble:coordinate.longitude forKey:longitudeKey];
        [userDefaults synchronize];
    }
}

- (BOOL)isValidCoordinate:(CLLocationCoordinate2D)coordinate
{
    BOOL isValidCoordinate = NO;
    if (CLLocationCoordinate2DIsValid(coordinate) && (coordinate.longitude != 0.0f && coordinate.latitude != 0.0f)) {
        isValidCoordinate = YES;
    }
    return isValidCoordinate;
}

@end
