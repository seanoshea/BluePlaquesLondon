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

static NSString *const BPLStateLastKnownBPLCoordinatLatitude = @"BPLStateLastKnownBPLCoordinatLatitude";
static NSString *const BPLStateLastKnownBPLCoordinatLongitude = @"BPLStateLastKnownBPLCoordinatLongitude";
static NSString *const BPLStateLastKnownCoordinatLatitude = @"BPLStateLastKnownCoordinatLatitude";
static NSString *const BPLStateLastKnownCoordinatLongitude = @"BPLStateLastKnownCoordinatLongitude";

@implementation NSUserDefaults (BPLState)

- (CLLocationCoordinate2D)lastKnownBPLCoordinate
{
    return [self savedCoordinateAtLatitude:BPLStateLastKnownBPLCoordinatLatitude longitude:BPLStateLastKnownBPLCoordinatLongitude];
}

- (void)saveLastKnownBPLCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self saveCoordinate:coordinate latitudeKey:BPLStateLastKnownBPLCoordinatLatitude longitudeKey:BPLStateLastKnownBPLCoordinatLongitude];
}

- (CLLocationCoordinate2D)lastKnownCoordinate
{
    return [self savedCoordinateAtLatitude:BPLStateLastKnownCoordinatLatitude longitude:BPLStateLastKnownCoordinatLongitude];
}

- (void)saveLastKnownCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self saveCoordinate:coordinate latitudeKey:BPLStateLastKnownCoordinatLatitude longitudeKey:BPLStateLastKnownCoordinatLongitude];
}

- (CLLocationCoordinate2D)savedCoordinateAtLatitude:(NSString *)latitude longitude:(NSString *)longitude
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    CLLocationDegrees latitudeDegrees = [userDefaults doubleForKey:BPLStateLastKnownBPLCoordinatLatitude];
    CLLocationDegrees longitudeDegrees = [userDefaults doubleForKey:BPLStateLastKnownBPLCoordinatLongitude];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitudeDegrees, longitudeDegrees);
    // check to see whether this is a valid lat/long coordinate.
    if (![self isValidCoordinate:coordinate]) {
        coordinate = CLLocationCoordinate2DMake(51.513611, -0.098056);
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
