/*
 Copyright (c) 2014 - 2015 Upwards Northwards Software Limited
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 3. All advertising materials mentioning features or use of this software
 must display the following acknowledgement:
 This product includes software developed by Upwards Northwards Software Limited.
 4. Neither the name of Upwards Northwards Software Limited nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY UPWARDS NORTHWARDS SOFTWARE LIMITED ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL UPWARDS NORTHWARDS SOFTWARE LIMITED BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <XCTest/XCTest.h>

#import "BPLTableViewCell.h"
#import "UIColor+BPLColors.h"

@interface BPLTableViewCellTest : XCTestCase

@property (nonatomic) BPLTableViewCell *closestCell;
@property (nonatomic) BPLTableViewCell *regularCell;

@end

@implementation BPLTableViewCellTest

- (void)setUp
{
    [super setUp];
    self.regularCell = [[BPLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BPLSearchCell];
    self.closestCell = [[BPLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BPLClosestCell];
}

- (void)testRegularCell
{
    XCTAssert(self.regularCell.textLabel.textColor == [UIColor BPLBlueColour], @"The text for a regular cell should be blue");
    XCTAssert(self.regularCell.accessoryType == UITableViewCellAccessoryDisclosureIndicator, @"There should be a disclosure inidicator for the cell");
}

- (void)testClosestCell
{
    XCTAssert(self.closestCell.textLabel.textColor == [UIColor whiteColor], @"The text for a regular cell should be white");
    XCTAssert(self.closestCell.backgroundColor == [UIColor BPLBlueColour], @"The background for a regular cell should be blue");
    XCTAssert(self.closestCell.accessoryType == UITableViewCellAccessoryDisclosureIndicator, @"There should be a disclosure inidicator for the cell");
}

@end
