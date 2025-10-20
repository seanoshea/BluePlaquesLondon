#import <XCTest/XCTest.h>
#import "BPLPlacemark.h"

@interface BPLPlacemarkTest : XCTestCase
@end

@implementation BPLPlacemarkTest

- (void)testPlacemarkCreation {
    BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
    XCTAssertNotNil(placemark);
}

- (void)testCoordinateProperty {
    BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
    placemark.latitude = @(51.5074);
    placemark.longitude = @(-0.1278);
    
    CLLocationCoordinate2D coordinate = placemark.coordinate;
    XCTAssertEqualWithAccuracy(coordinate.latitude, 51.5074, 0.0001);
    XCTAssertEqualWithAccuracy(coordinate.longitude, -0.1278, 0.0001);
}

- (void)testKeyProperty {
    BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
    placemark.latitude = @(51.5074);
    placemark.longitude = @(-0.1278);
    
    NSString *key = placemark.key;
    XCTAssertNotNil(key);
    XCTAssertTrue([key containsString:@"51.5074"]);
    XCTAssertTrue([key containsString:@"-0.1278"]);
}

- (void)testPlacemarkTitleProperty {
    BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
    placemark.name = @"Test Plaque";
    
    NSString *title = placemark.placemarkTitle;
    XCTAssertEqualObjects(title, @"Test Plaque");
}

- (void)testOccupationProperty {
    BPLPlacemark *placemark = [[BPLPlacemark alloc] init];
    placemark.featureDescription = @"<description>Writer and poet</description>";
    
    NSString *occupation = placemark.occupation;
    XCTAssertNotNil(occupation);
    XCTAssertTrue([occupation containsString:@"Writer"]);
}

@end