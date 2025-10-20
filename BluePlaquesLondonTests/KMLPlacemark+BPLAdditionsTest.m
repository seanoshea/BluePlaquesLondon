#import <XCTest/XCTest.h>
#import "KMLPlacemark+BPLAdditions.h"

@interface KMLPlacemarkBPLAdditionsTest : XCTestCase
@end

@implementation KMLPlacemarkBPLAdditionsTest

- (void)testBPLPlacemarkConversion {
    KMLPlacemark *kmlPlacemark = [[KMLPlacemark alloc] init];
    kmlPlacemark.name = @"Test Plaque";
    kmlPlacemark.descriptionValue = @"Test description";
    
    BPLPlacemark *bplPlacemark = [kmlPlacemark BPLPlacemark];
    XCTAssertNotNil(bplPlacemark);
    XCTAssertEqualObjects(bplPlacemark.name, @"Test Plaque");
    XCTAssertEqualObjects(bplPlacemark.featureDescription, @"Test description");
}

- (void)testBPLPlacemarkWithGeometry {
    KMLPlacemark *kmlPlacemark = [[KMLPlacemark alloc] init];
    kmlPlacemark.name = @"Test Plaque";
    
    KMLPoint *point = [[KMLPoint alloc] init];
    KMLCoordinate *coordinate = [[KMLCoordinate alloc] init];
    coordinate.latitude = 51.5074;
    coordinate.longitude = -0.1278;
    point.coordinate = coordinate;
    kmlPlacemark.geometry = point;
    
    BPLPlacemark *bplPlacemark = [kmlPlacemark BPLPlacemark];
    XCTAssertNotNil(bplPlacemark);
    XCTAssertEqualWithAccuracy([bplPlacemark.latitude doubleValue], 51.5074, 0.0001);
    XCTAssertEqualWithAccuracy([bplPlacemark.longitude doubleValue], -0.1278, 0.0001);
}

- (void)testBPLPlacemarkWithNilGeometry {
    KMLPlacemark *kmlPlacemark = [[KMLPlacemark alloc] init];
    kmlPlacemark.name = @"Test Plaque";
    kmlPlacemark.geometry = nil;
    
    BPLPlacemark *bplPlacemark = [kmlPlacemark BPLPlacemark];
    XCTAssertNotNil(bplPlacemark);
    XCTAssertEqualObjects(bplPlacemark.name, @"Test Plaque");
}

@end