#import <XCTest/XCTest.h>
#import "BPLLabel.h"

@interface BPLLabelTest : XCTestCase
@end

@implementation BPLLabelTest

- (void)testLabelCreation {
    BPLLabel *label = [[BPLLabel alloc] init];
    XCTAssertNotNil(label);
    XCTAssertTrue([label isKindOfClass:[UILabel class]]);
}

- (void)testLabelWithFrame {
    CGRect frame = CGRectMake(0, 0, 100, 50);
    BPLLabel *label = [[BPLLabel alloc] initWithFrame:frame];
    XCTAssertNotNil(label);
    XCTAssertTrue(CGRectEqualToRect(label.frame, frame));
}

- (void)testDefaultProperties {
    BPLLabel *label = [[BPLLabel alloc] init];
    
    // Test any default styling that might be applied
    XCTAssertNotNil(label.font);
    XCTAssertNotNil(label.textColor);
}

@end