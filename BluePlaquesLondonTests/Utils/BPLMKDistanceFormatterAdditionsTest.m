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
#import "MKDistanceFormatter+BPLAdditions.h"

@interface BPLMKDistanceFormatterAdditionsTest : XCTestCase

@end

@implementation BPLMKDistanceFormatterAdditionsTest

- (void)testRetrieveLastKnownBPLCoordinate
{
    
    CLLocation *from = [[CLLocation alloc] initWithLatitude:50.001 longitude:0.0012456];
    CLLocation *to = [[CLLocation alloc] initWithLatitude:0.12345 longitude:25.987];
    NSString *distance = [MKDistanceFormatter distanceFromLocation:from toLocation:to];
    XCTAssert(distance != nil, @"The distance returned from `distanceFromLocation` should not be nil");
    
}

@end
