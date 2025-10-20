#import <XCTest/XCTest.h>
#import "UIColor+BPLColors.h"

@interface UIColorBPLColorsTest : XCTestCase
@end

@implementation UIColorBPLColorsTest

- (void)testBPLBlueColour {
    UIColor *blue = [UIColor BPLBlueColour];
    XCTAssertNotNil(blue);
    
    CGFloat red, green, blue_component, alpha;
    [blue getRed:&red green:&green blue:&blue_component alpha:&alpha];
    
    XCTAssertEqualWithAccuracy(red, 0.0, 0.1);
    XCTAssertEqualWithAccuracy(green, 0.0, 0.1);
    XCTAssertEqualWithAccuracy(blue_component, 1.0, 0.1);
    XCTAssertEqualWithAccuracy(alpha, 1.0, 0.01);
}

- (void)testBPLLightGreyColour {
    UIColor *lightGrey = [UIColor BPLLightGreyColour];
    XCTAssertNotNil(lightGrey);
    
    CGFloat red, green, blue, alpha;
    [lightGrey getRed:&red green:&green blue:&blue alpha:&alpha];
    
    XCTAssertEqualWithAccuracy(alpha, 1.0, 0.01);
    XCTAssertTrue(red > 0.8 && green > 0.8 && blue > 0.8); // Light grey values
}

@end