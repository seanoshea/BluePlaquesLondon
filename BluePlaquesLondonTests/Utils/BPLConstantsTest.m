#import <XCTest/XCTest.h>
#import "BPLConstants.h"

@interface BPLConstantsTest : XCTestCase
@end

@implementation BPLConstantsTest

- (void)testConstants {
    XCTAssertNotNil(BPLApplicationURLSchemeIdentifier);
    XCTAssertTrue([BPLApplicationURLSchemeIdentifier isEqualToString:@"blueplaqueslondon"]);
    
    XCTAssertNotNil(BPLKMZFilename);
    XCTAssertTrue([BPLKMZFilename isEqualToString:@"blueplaques"]);
    
    XCTAssertNotNil(BPLUIActionCategory);
    XCTAssertNotNil(BPLTodayExtensionButtonPressed);
}

- (void)testMapsKeyLoading {
    // BPLMapsKey should be nil initially (loaded from plist at runtime)
    XCTAssertNil(BPLMapsKey);
}

@end