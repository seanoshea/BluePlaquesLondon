#import <XCTest/XCTest.h>
#import "NSUserDefaults+BPLState.h"

@interface NSUserDefaultsBPLStateTest : XCTestCase
@end

@implementation NSUserDefaultsBPLStateTest

- (void)setUp {
    [super setUp];
    // Clear any existing state
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BPLLastKnownLatitude"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BPLLastKnownLongitude"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BPLMapZoom"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)testDefaultCoordinate {
    CLLocationCoordinate2D coordinate = [[NSUserDefaults standardUserDefaults] BPLLastKnownCoordinate];
    
    // Should return London coordinates as default
    XCTAssertEqualWithAccuracy(coordinate.latitude, 51.5074, 0.0001);
    XCTAssertEqualWithAccuracy(coordinate.longitude, -0.1278, 0.0001);
}

- (void)testSetAndGetCoordinate {
    CLLocationCoordinate2D testCoordinate = CLLocationCoordinate2DMake(52.5200, 13.4050); // Berlin
    
    [[NSUserDefaults standardUserDefaults] setBPLLastKnownCoordinate:testCoordinate];
    CLLocationCoordinate2D retrievedCoordinate = [[NSUserDefaults standardUserDefaults] BPLLastKnownCoordinate];
    
    XCTAssertEqualWithAccuracy(retrievedCoordinate.latitude, 52.5200, 0.0001);
    XCTAssertEqualWithAccuracy(retrievedCoordinate.longitude, 13.4050, 0.0001);
}

- (void)testDefaultMapZoom {
    float zoom = [[NSUserDefaults standardUserDefaults] BPLMapZoom];
    XCTAssertEqualWithAccuracy(zoom, 15.0f, 0.01f);
}

- (void)testSetAndGetMapZoom {
    float testZoom = 12.5f;
    
    [[NSUserDefaults standardUserDefaults] setBPLMapZoom:testZoom];
    float retrievedZoom = [[NSUserDefaults standardUserDefaults] BPLMapZoom];
    
    XCTAssertEqualWithAccuracy(retrievedZoom, testZoom, 0.01f);
}

@end