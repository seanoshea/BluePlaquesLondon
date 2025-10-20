#import <XCTest/XCTest.h>
#import "BPLConfiguration.h"

@interface BPLConfigurationTest : XCTestCase
@end

@implementation BPLConfigurationTest

- (void)testSharedConfiguration {
    BPLConfiguration *config1 = [BPLConfiguration sharedConfiguration];
    BPLConfiguration *config2 = [BPLConfiguration sharedConfiguration];
    
    XCTAssertNotNil(config1);
    XCTAssertEqual(config1, config2); // Singleton
}

- (void)testDefaultValues {
    BPLConfiguration *config = [BPLConfiguration sharedConfiguration];
    
    XCTAssertTrue(config.mapZoom > 0);
    XCTAssertNotNil(config.lastKnownCoordinate);
    XCTAssertTrue(config.lastKnownCoordinate.latitude != 0 || config.lastKnownCoordinate.longitude != 0);
}

- (void)testCoordinateUpdate {
    BPLConfiguration *config = [BPLConfiguration sharedConfiguration];
    CLLocationCoordinate2D originalCoordinate = config.lastKnownCoordinate;
    
    CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake(51.5074, -0.1278); // London
    config.lastKnownCoordinate = newCoordinate;
    
    XCTAssertEqualWithAccuracy(config.lastKnownCoordinate.latitude, 51.5074, 0.0001);
    XCTAssertEqualWithAccuracy(config.lastKnownCoordinate.longitude, -0.1278, 0.0001);
    
    // Restore original
    config.lastKnownCoordinate = originalCoordinate;
}

@end