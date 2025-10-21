#import <XCTest/XCTest.h>
#import "UIColor+BPLColors.h"

@interface UIColorBPLColorsTest : XCTestCase
@end

@implementation UIColorBPLColorsTest

- (void)testBPLBlueColour {
    UIColor *color = [UIColor BPLBlueColour];
    XCTAssertNotNil(color);
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertEqualWithAccuracy(alpha, 1.0, 0.01);
}

- (void)testBPLDarkGreyColour {
    UIColor *color = [UIColor BPLDarkGreyColour];
    XCTAssertNotNil(color);
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertEqualWithAccuracy(alpha, 1.0, 0.01);
}

- (void)testBPLGreyColour {
    UIColor *color = [UIColor BPLGreyColour];
    XCTAssertNotNil(color);
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertEqualWithAccuracy(alpha, 1.0, 0.01);
}

- (void)testBPLLightGreyColour {
    UIColor *color = [UIColor BPLLightGreyColour];
    XCTAssertNotNil(color);
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertEqualWithAccuracy(alpha, 1.0, 0.01);
    XCTAssertTrue(red > 0.8 && green > 0.8 && blue > 0.8);
}

- (void)testBPLOrangeColour {
    UIColor *color = [UIColor BPLOrangeColour];
    XCTAssertNotNil(color);
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertEqualWithAccuracy(alpha, 1.0, 0.01);
}

- (void)testBPLLightOrangeColour {
    UIColor *color = [UIColor BPLLightOrangeColour];
    XCTAssertNotNil(color);
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    XCTAssertTrue(alpha > 0.0 && alpha <= 1.0);
}

@end
