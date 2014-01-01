//
//  BPLTableViewCellTest.m
//  BluePlaquesLondon
//
//  Created by seanoshea on 01/01/2014.
//  Copyright (c) 2014 UpwardsNorthwards. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "BPLTableViewCell.h"
#import "UIColor+BluePlaquesLondon.h"

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
