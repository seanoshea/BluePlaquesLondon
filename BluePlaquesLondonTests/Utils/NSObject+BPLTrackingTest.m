#import <XCTest/XCTest.h>
#import "NSObject+BPLTracking.h"

@interface NSObjectBPLTrackingTest : XCTestCase
@end

@implementation NSObjectBPLTrackingTest

- (void)testTrackingMethods {
    NSObject *testObject = [[NSObject alloc] init];
    
    // Test that tracking methods don't crash
    XCTAssertNoThrow([testObject trackCategory:@"Test" action:@"Action" label:@"Label"]);
    XCTAssertNoThrow([testObject trackCategory:@"Test" action:@"Action" label:nil]);
    XCTAssertNoThrow([testObject trackCategory:@"Test" action:@"Action" label:@"Label" value:@(42)]);
}

- (void)testTrackingWithNilParameters {
    NSObject *testObject = [[NSObject alloc] init];
    
    // Test with nil parameters
    XCTAssertNoThrow([testObject trackCategory:nil action:@"Action" label:@"Label"]);
    XCTAssertNoThrow([testObject trackCategory:@"Test" action:nil label:@"Label"]);
    XCTAssertNoThrow([testObject trackCategory:nil action:nil label:nil]);
}

- (void)testTrackingWithEmptyStrings {
    NSObject *testObject = [[NSObject alloc] init];
    
    // Test with empty strings
    XCTAssertNoThrow([testObject trackCategory:@"" action:@"" label:@""]);
    XCTAssertNoThrow([testObject trackCategory:@"Test" action:@"" label:@"Label"]);
}

@end