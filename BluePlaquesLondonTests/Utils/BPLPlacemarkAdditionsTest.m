/*
 Copyright (c) 2014 - present Upwards Northwards Software Limited
 All rights reserved.
 */

#import <XCTest/XCTest.h>
#import "BPLPlacemark+Additions.h"
#import "BPLPlacemark.h"

@interface BPLPlacemarkAdditionsTest : XCTestCase
@end

@implementation BPLPlacemarkAdditionsTest

- (void)testCoordinate
{
  BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
  placemark.latitude = @(51.5074);
  placemark.longitude = @(-0.1278);
  
  CLLocationCoordinate2D coordinate = [placemark coordinate];
  
  XCTAssertEqual(coordinate.latitude, 51.5074, @"Latitude should match");
  XCTAssertEqual(coordinate.longitude, -0.1278, @"Longitude should match");
}

- (void)testCoordinateWithNilValues
{
  BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
  
  CLLocationCoordinate2D coordinate = [placemark coordinate];
  
  XCTAssertEqual(coordinate.latitude, 0.0, @"Latitude should be 0 when nil");
  XCTAssertEqual(coordinate.longitude, 0.0, @"Longitude should be 0 when nil");
}

@end
