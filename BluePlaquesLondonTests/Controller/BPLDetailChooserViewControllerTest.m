/*
 Copyright (c) 2014 - present Upwards Northwards Software Limited
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>


#import "BPLDetailChooserViewController.h"

#import "BPLPlacemark.h"
#import "BPLUnitTestHelper.h"
#import "BPLConstants.h"

@interface BPLDetailChooserViewControllerTest : XCTestCase

@property (nonatomic) UINavigationController *navigationController;
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
  
  UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  
  self.controller = [storybord instantiateViewControllerWithIdentifier:BPLDetailChooserViewControllerStoryboardIdentifier];
  self.controller.markers = self.markers;
  self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.controller];
}

- (void)testTitle {
  [self.controller viewWillAppear:YES];
  XCTAssertTrue([self.controller.title isEqualToString:NSLocalizedString(@"Choose one", nil)]);
}

- (void)testNumberOfSections {
  NSInteger numberOfSections = [self.controller numberOfSectionsInCollectionView:self.controller.collectionView];
  
  XCTAssertTrue(numberOfSections == 1);
}

- (void)testNumberOfRowsInSection {
  NSInteger numberOfRowsInSectionZero = [self.controller collectionView:self.controller.collectionView numberOfItemsInSection:0];
  NSInteger numberOfRowsInSectionOne = [self.controller collectionView:self.controller.collectionView numberOfItemsInSection:1];
  
  XCTAssertTrue(numberOfRowsInSectionZero == 2);
  XCTAssertTrue(numberOfRowsInSectionOne == 2);
}

- (void)testRetrievingACellFromTheTable {
  MDCCollectionViewTextCell *cell = (MDCCollectionViewTextCell *)[self.controller collectionView:self.controller.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
  
  XCTAssertTrue([cell.textLabel.text isEqualToString:@"Feature Description 1"]);
}

@end
