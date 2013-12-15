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

#import "SimpleKMLPlacemark+Additions.h"

@interface BPLSimpleKMLAdditionTests : XCTestCase

@property (nonatomic, copy) SimpleKMLPlacemark *examplePlacemark;
@property (nonatomic, copy) SimpleKMLPlacemark *examplePlacemarkWithNote;

@end

@implementation BPLSimpleKMLAdditionTests

- (void)setUp {
    
    self.examplePlacemark = [[SimpleKMLPlacemark alloc] init];
    self.examplePlacemark.featureDescription = @"WANAMAKER, Sam (1919-1993)<br> The man behind Shakespeare's Globe<br> New Globe Buildings, Bankside, SE1<br> Southwark 2003<br> Southwark Council Plaque";
    self.examplePlacemarkWithNote = [[SimpleKMLPlacemark alloc] init];
    self.examplePlacemarkWithNote.featureDescription = @"GAINSBOROUGH, Thomas (1727-1788)<br> Artist, lived here<br> 80 - 82 Pall Mall, SW1<br> Westminster 1951<br> <em>Note: Replaces plaque up in 1881 by RSA at No. 80.</em>";
}

- (void)testExtractOverlayTitle
{
    NSString *overlayTitle = self.examplePlacemark.overlayTitle;
    XCTAssert([overlayTitle isEqualToString:@"WANAMAKER, Sam (1919-1993)"], @"The title should contain the name and birth dates");
}

- (void)testExtractOverlaySubtitle
{
    NSString *overlaySubtitle = self.examplePlacemark.overlaySubtitle;
    XCTAssert([overlaySubtitle isEqualToString:@"The man behind Shakespeare's Globe  New Globe Buildings, Bankside, SE1  Southwark 2003  Southwark Council Plaque"], @"The subtitle should only include ancillary information");
}

- (void)testExtractOccupation
{
    NSString *occupation = self.examplePlacemark.occupation;
    XCTAssert([occupation isEqualToString:@"The man behind Shakespeare's Globe"], @"The occupation should only include the reason the plaque was commerated in the first place");
}

- (void)testExtractAddress
{
    NSString *address = self.examplePlacemark.address;
    XCTAssert([address isEqualToString:@"New Globe Buildings, Bankside, SE1"], @"The address should only include the plaque's human-readable location");
}

- (void)testExtractNote
{
    NSString *occupation = self.examplePlacemarkWithNote.note;
    XCTAssert([occupation isEqualToString:@"Note: Replaces plaque up in 1881 by RSA at No. 80."], @"The note should only include exactly what is in between <em></em> tags");
}

@end
