#import <XCTest/XCTest.h>
#import "BPLInfoWindow.h"

@interface BPLInfoWindowTest : XCTestCase
@end

@implementation BPLInfoWindowTest

- (void)testInfoWindowCreation {
    BPLInfoWindow *infoWindow = [[BPLInfoWindow alloc] init];
    XCTAssertNotNil(infoWindow);
    XCTAssertTrue([infoWindow isKindOfClass:[UIView class]]);
}

- (void)testInfoWindowWithFrame {
    CGRect frame = CGRectMake(0, 0, 200, 100);
    BPLInfoWindow *infoWindow = [[BPLInfoWindow alloc] initWithFrame:frame];
    XCTAssertNotNil(infoWindow);
    XCTAssertTrue(CGRectEqualToRect(infoWindow.frame, frame));
}

- (void)testOutlets {
    BPLInfoWindow *infoWindow = [[BPLInfoWindow alloc] init];
    
    // Test that outlets can be set (they might be nil initially)
    XCTAssertNoThrow(infoWindow.titleLabel = [[UILabel alloc] init]);
    XCTAssertNoThrow(infoWindow.occupationLabel = [[UILabel alloc] init]);
}

@end