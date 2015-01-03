/*
 Copyright 2013 - 2015 Sean O'Shea
 
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

#import <XCTest/XCTest.h>

#import "NSUserDefaults+BPLState.h"

@interface BPLStateTest : XCTestCase

@end

@implementation BPLStateTest

- (void)testRetrieveLastKnownCoordinate
{
    CLLocationCoordinate2D coordinate = [[NSUserDefaults standardUserDefaults] lastKnownCoordinate];
    XCTAssert(coordinate.latitude != 0.0f && coordinate.longitude != 0.0f, @"Should always return at least a default coordinate for lastKnownCoordinate");
}

- (void)testRetrieveLastKnownBPLCoordinate
{
    CLLocationCoordinate2D coordinate = [[NSUserDefaults standardUserDefaults] lastKnownBPLCoordinate];
    XCTAssert(coordinate.latitude != 0.0f && coordinate.longitude != 0.0f, @"Should always return at least a default coordinate for lastKnownBPLCoordinate");
}

- (void)testRetrieveZoom
{
    float zoom = [[NSUserDefaults standardUserDefaults] mapZoom];
    XCTAssert(zoom > 0.0f, @"Should always return a positive zoom default");
}

- (void)testSaveZoom
{
    float theDefaultIAmTryingToSet = 6.0f;
    [[NSUserDefaults standardUserDefaults] saveMapZoom:theDefaultIAmTryingToSet];
    float after = [[NSUserDefaults standardUserDefaults] mapZoom];
    XCTAssert(after == theDefaultIAmTryingToSet, @"Saving the map zoom should be automatically saved to the defaults");
}

- (void)testSaveLastKnownCoordinate
{
    [[NSUserDefaults standardUserDefaults] saveLastKnownCoordinate:CLLocationCoordinate2DMake(0.1f, 0.2f)];
    CLLocationCoordinate2D after = [[NSUserDefaults standardUserDefaults] lastKnownCoordinate];
    XCTAssert(after.latitude == 0.1f && after.longitude == 0.2f, @"Saving the last known coordinate should be automatically saved to the defaults");
}

- (void)testSaveLastKnownBPLCoordinate
{
    [[NSUserDefaults standardUserDefaults] saveLastKnownBPLCoordinate:CLLocationCoordinate2DMake(0.1f, 0.2f)];
    CLLocationCoordinate2D after = [[NSUserDefaults standardUserDefaults] lastKnownBPLCoordinate];
    XCTAssert(after.latitude == 0.1f && after.longitude == 0.2f, @"Saving the last known BPL coordinate should be automatically saved to the defaults");
}

- (void)tearDown
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

@end
