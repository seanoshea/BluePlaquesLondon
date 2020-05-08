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

#import <XCTest/XCTest.h>

#import "NSUserDefaults+BPLState.h"

@interface BPLStateTest : XCTestCase

@end

@implementation BPLStateTest

- (void)testRetrieveLastKnownCoordinate
{
  CLLocationCoordinate2D coordinate = [NSUserDefaults standardUserDefaults].lastKnownCoordinate;
  XCTAssert(coordinate.latitude != 0.0f && coordinate.longitude != 0.0f, @"Should always return at least a default coordinate for lastKnownCoordinate");
}

- (void)testRetrieveLastKnownBPLCoordinate
{
  CLLocationCoordinate2D coordinate = [NSUserDefaults standardUserDefaults].lastKnownBPLCoordinate;
  XCTAssert(coordinate.latitude != 0.0f && coordinate.longitude != 0.0f, @"Should always return at least a default coordinate for lastKnownBPLCoordinate");
}

- (void)testRetrieveZoom
{
  float zoom = [NSUserDefaults standardUserDefaults].mapZoom;
  XCTAssert(zoom > 0.0f, @"Should always return a positive zoom default");
}

- (void)testSaveZoom
{
  float theDefaultIAmTryingToSet = 6.0f;
  [[NSUserDefaults standardUserDefaults] saveMapZoom:theDefaultIAmTryingToSet];
  float after = [NSUserDefaults standardUserDefaults].mapZoom;
  XCTAssert(after == theDefaultIAmTryingToSet, @"Saving the map zoom should be automatically saved to the defaults");
}

- (void)testSaveLastKnownCoordinate
{
  [[NSUserDefaults standardUserDefaults] saveLastKnownCoordinate:CLLocationCoordinate2DMake(0.1f, 0.2f)];
  CLLocationCoordinate2D after = [NSUserDefaults standardUserDefaults].lastKnownCoordinate;
  XCTAssert(after.latitude == 0.1f && after.longitude == 0.2f, @"Saving the last known coordinate should be automatically saved to the defaults");
}

- (void)testSaveLastKnownBPLCoordinate
{
  [[NSUserDefaults standardUserDefaults] saveLastKnownBPLCoordinate:CLLocationCoordinate2DMake(0.1f, 0.2f)];
  CLLocationCoordinate2D after = [NSUserDefaults standardUserDefaults].lastKnownBPLCoordinate;
  XCTAssert(after.latitude == 0.1f && after.longitude == 0.2f, @"Saving the last known BPL coordinate should be automatically saved to the defaults");
}

- (void)tearDown
{
  NSString *appDomain = [NSBundle mainBundle].bundleIdentifier;
  [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

@end
