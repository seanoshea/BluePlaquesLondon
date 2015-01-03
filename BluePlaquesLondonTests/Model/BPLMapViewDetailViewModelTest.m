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

#import "BPLMapViewDetailViewModel.h"

@interface BPLMapViewDetailViewModelTest : XCTestCase

@end

@implementation BPLMapViewDetailViewModelTest

- (void)testInitialisation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:50.0123 longitude:0.0123];
    NSArray *markers = @[];
    BPLMapViewDetailViewModel *model = [[BPLMapViewDetailViewModel alloc] initWithMarkers:markers currentLocation:location];
    XCTAssert(model.currentLocation.coordinate.latitude == 50.0123, @"The latitude should be persisted during initialisation");
    XCTAssert(model.currentLocation.coordinate.longitude == 0.0123, @"The latitude should be persisted during initialisation");
    XCTAssert(model.markers.count == 0, @"The markers should be persisted during initialisation");
}

@end
