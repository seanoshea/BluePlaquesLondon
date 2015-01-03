/*
 Copyright 2013 - 2015 Sean O'Shea
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <XCTest/XCTest.h>

#import "BPLButton.h"
#import "UIColor+BPLColors.h"

@interface BPLButtonTest : XCTestCase

@property (nonatomic) BPLButton *button;

@end

@implementation BPLButtonTest

- (void)setUp
{
    [super setUp];
    self.button = [[BPLButton alloc] initWithCoder:nil];
}

- (void)testHighlightedColours
{
    self.button.highlighted = NO;
    XCTAssert([self.button.backgroundColor isEqual:[UIColor whiteColor]], @"The background should be white when the button is not highlighted");
    self.button.highlighted = YES;
    XCTAssert([self.button.backgroundColor isEqual:[UIColor BPLBlueColour]], @"The background should be blue when the button is highlighted");
}

@end
