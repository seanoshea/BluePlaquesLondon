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

@interface BPLDetailChooserViewControllerTest : XCTestCase

@property (nonatomic) BPLDetailChooserViewController *controller;
@property (nonatomic, copy) NSArray *markers;

@end

@interface BPLDetailChooserViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation BPLDetailChooserViewControllerTest

- (void)setUp {
    [super setUp];
    
    BPLPlacemark *marker1 = [[BPLPlacemark alloc] init];
    marker1.featureDescription = @"Feature Description 1";
    marker1.name = @"Name 1";
    marker1.title = @"Title 1";
    marker1.styleUrl = @"Style URL 1";
    marker1.longitude = @(0);
    marker1.latitude = @(1);
    marker1.placemarkPinType = @(1);
    
    BPLPlacemark *marker2 = [[BPLPlacemark alloc] init];
    marker2.featureDescription = @"Feature Description 2";
    marker2.name = @"Name 2";
    marker2.title = @"Title 2";
    marker2.styleUrl = @"Style URL 2";
    marker2.longitude = @(1);
    marker2.latitude = @(0);
    marker2.placemarkPinType = @(0);
    
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
