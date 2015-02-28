//
//  BPLDetailChooserViewControllerTest.m
//  BluePlaquesLondon
//
//  Created by Sean O Shea on 2/26/15.
//  Copyright (c) 2015 Sean O'Shea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "BPLDetailChooserViewController.h"

#import "BPLPlacemark.h"
#import "BPLUnitTestHelper.h"

@interface BPLDetailChooserViewControllerTest : XCTestCase

@property (nonatomic) BPLDetailChooserViewController *controller;
@property (nonatomic, copy) NSArray *markers;

@end

@interface BPLDetailChooserViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation BPLDetailChooserViewControllerTest

- (void)setUp {
    [super setUp];
    
    BPLPlacemark *marker1 = [BPLUnitTestHelper placemarkWithIdentifier:@"1"];
    BPLPlacemark *marker2 = [BPLUnitTestHelper placemarkWithIdentifier:@"2"];
    
    self.markers = @[marker1, marker2];
    
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    self.controller = [storybord instantiateViewControllerWithIdentifier:BPLDetailChooserViewControllerStoryboardIdentifier];
    self.controller.markers = self.markers;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testTitle {
    [self.controller viewWillAppear:YES];
    XCTAssertTrue([self.controller.title isEqualToString:NSLocalizedString(@"Choose one", nil)]);
}

- (void)testNumberOfSections {
    NSInteger numberOfSections = [self.controller numberOfSectionsInTableView:nil];
    
    XCTAssertTrue(numberOfSections == 1);
}

- (void)testNumberOfRowsInSection {
    NSInteger numberOfRowsInSectionZero = [self.controller tableView:nil numberOfRowsInSection:0];
    NSInteger numberOfRowsInSectionOne = [self.controller tableView:nil numberOfRowsInSection:1];
    
    XCTAssertTrue(numberOfRowsInSectionZero == 2);
    XCTAssertTrue(numberOfRowsInSectionOne == 2);
}

- (void)testRetrievingACellFromTheTable {
    
    UITableViewCell *cell = [self.controller tableView:self.controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    XCTAssertTrue([cell.textLabel.text isEqualToString:@"Feature Description 1"]);
}

@end
