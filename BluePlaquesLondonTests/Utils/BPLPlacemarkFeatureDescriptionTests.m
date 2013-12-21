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

#import "NSString+BPLPlacemarkFeatureDescription.h"

@interface BPLPlacemarkFeatureDescriptionTests : XCTestCase

@property (nonatomic, copy) NSString *wanamaker;
@property (nonatomic, copy) NSString *gainsborough;
@property (nonatomic, copy) NSString *holst;

@end

@implementation BPLPlacemarkFeatureDescriptionTests

- (void)setUp
{
    [super setUp];
    self.wanamaker = @"WANAMAKER, Sam (1919-1993)<br> The man behind Shakespeare's Globe<br> New Globe Buildings, Bankside, SE1<br> Southwark 2003<br> Southwark Council Plaque";
    self.gainsborough = @"GAINSBOROUGH, Thomas (1727-1788)<br> Artist, lived here<br> 80 - 82 Pall Mall, SW1<br> Westminster 1951<br> <em>Note: Replaces plaque up in 1881 by RSA at No. 80.</em>";
    self.holst = @"HOLST, Gustav (1874-1934)<br>Composer, wrote, <em>The Planets</em>, and, taught here<br>St Paul's Girls' School, Brook Green, W8<br>Hammersmith and Fulham 2004";
}

- (void)testExtractName
{
    NSString *name = self.wanamaker.name;
    XCTAssert([name isEqualToString:@"WANAMAKER, Sam"], @"The name should only contain the person's full name and not the dates");
}

- (void)testExtractTitle
{
    NSString *title = self.wanamaker.title;
    XCTAssert([title isEqualToString:@"WANAMAKER, Sam (1919-1993)"], @"The title should contain the name and birth dates");
}

- (void)testExtractSubtitle
{
    NSString *subtitle = self.wanamaker.subtitle;
    XCTAssert([subtitle isEqualToString:@"The man behind Shakespeare's Globe  New Globe Buildings, Bankside, SE1  Southwark 2003"], @"The subtitle should only include ancillary information");
}

- (void)testExtractOccupation
{
    NSString *occupation = self.wanamaker.occupation;
    XCTAssert([occupation isEqualToString:@"The man behind Shakespeare's Globe"], @"The occupation should only include the reason the plaque was commerated in the first place");
}

- (void)testExtractAddress
{
    NSString *address = self.wanamaker.address;
    XCTAssert([address isEqualToString:@"New Globe Buildings, Bankside, SE1"], @"The address should only include the plaque's human-readable location");
}

- (void)testExtractNote
{
    NSString *occupation = self.gainsborough.note;
    XCTAssert([occupation isEqualToString:@"Note: Replaces plaque up in 1881 by RSA at No. 80."], @"The note should only include exactly what is in between <em></em> tags");
}

@end
