/*
 Copyright 2012 - 2013 UpwardsNorthwards
 
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

#import "NSString+MapOverlayAdditions.h"

@interface BPLMapOverlayAdditionTests : XCTestCase

@property (nonatomic, copy) NSString *exampleString;

@end

@implementation BPLMapOverlayAdditionTests

- (void)setUp {
    
    self.exampleString = @"WANAMAKER, Sam (1919-1993)<br> The man behind Shakespeare's Globe<br> New Globe Buildings, Bankside, SE1<br> Southwark 2003<br> Southwark Council Plaque";
}

- (void)testExtractOverlayTitle
{
    NSString *overlayTitle = [self.exampleString overlayTitle];
    XCTAssert([overlayTitle isEqualToString:@"WANAMAKER, Sam (1919-1993)"], @"The title should contain the name and birth dates");
}

- (void)testExtractOverlaySubtitle
{
    NSString *overlaySubtitle = [self.exampleString overlaySubtitle];
    XCTAssert([overlaySubtitle isEqualToString:@"The man behind Shakespeare's Globe  New Globe Buildings, Bankside, SE1  Southwark 2003  Southwark Council Plaque"], @"The subtitle should only include ancillary information");
}

@end
