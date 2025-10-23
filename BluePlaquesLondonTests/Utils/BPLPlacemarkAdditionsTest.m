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

- (void)testPlacemarkNameWithNilFeatureDescription
{
  BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
  placemark.featureDescription = nil;
  
  NSString *name = [placemark placemarkName];
  
  XCTAssertNil(name, @"Name should be nil when featureDescription is nil");
}

- (void)testPlacemarkTitleWithNilFeatureDescription
{
  BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
  placemark.featureDescription = nil;
  
  NSString *title = [placemark placemarkTitle];
  
  XCTAssertNil(title, @"Title should be nil when featureDescription is nil");
}

- (void)testKeyGeneration
{
  BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
  placemark.latitude = @(51.50170);
  placemark.longitude = @(-0.18147);
  
  NSString *key = [placemark key];
  
  XCTAssertNotNil(key, @"Key should not be nil");
  XCTAssertTrue([key containsString:@"51.50170"], @"Key should contain latitude");
  XCTAssertTrue([key containsString:@"-0.18147"], @"Key should contain longitude");
}

- (void)testKeyGenerationWithNilCoordinates
{
  BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
  
  NSString *key = [placemark key];
  
  XCTAssertNotNil(key, @"Key should not be nil even with nil coordinates");
  XCTAssertTrue([key containsString:@"0.00000"], @"Key should contain default coordinate values");
}

@end
