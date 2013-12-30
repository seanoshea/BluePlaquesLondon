/*
 Copyright 2012 - 2013 UpwardsNorthwards
 
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

#import "NSUserDefaults+BPLState.h"

#import <GoogleMaps/GoogleMaps.h>

static NSString *const BPLStateLastKnownBPLCoordinatLatitude = @"BPLStateLastKnownBPLCoordinatLatitude";
static NSString *const BPLStateLastKnownBPLCoordinatLongitude = @"BPLStateLastKnownBPLCoordinatLongitude";
static NSString *const BPLStateLastKnownCoordinatLatitude = @"BPLStateLastKnownCoordinatLatitude";
static NSString *const BPLStateLastKnownCoordinatLongitude = @"BPLStateLastKnownCoordinatLongitude";

static NSString *const BPLStateMapZoom = @"BPLStateMapZoom";
static float const BPLStateMapZoomDefault = 15.0f;

static NSString *const BPLTrackingEnabled = @"BPLTrackingEnabled";

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
        coordinate = CLLocationCoordinate2DMake(51.50016999993306, -0.1814680000049975);
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
