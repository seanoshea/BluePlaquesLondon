#import <XCTest/XCTest.h>
#import "UIColor+BPLColors.h"

@interface UIColorBPLColorsTest : XCTestCase
@end

@implementation UIColorBPLColorsTest

- (void)testBPLLightGreyColour {
    UIColor *lightGrey = [UIColor BPLLightGreyColour];
    XCTAssertNotNil(lightGrey);
    
    CGFloat red, green, blue, alpha;
    [lightGrey getRed:&red green:&green blue:&blue alpha:&alpha];
    
    XCTAssertEqualWithAccuracy(alpha, 1.0, 0.01);
    XCTAssertTrue(red > 0.8 && green > 0.8 && blue > 0.8); // Light grey values
}

@end
