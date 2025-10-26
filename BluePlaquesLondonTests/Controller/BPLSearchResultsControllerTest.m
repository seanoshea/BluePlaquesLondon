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

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "BPLSearchResultsController.h"
#import "BPLMapViewModel.h"
#import "BPLUnitTestHelper.h"

@interface BPLSearchResultsController ()

@property (nonatomic) UICollectionView *collectionView;

@end

@interface BPLSearchResultsControllerTest : XCTestCase

@property (nonatomic) BPLSearchResultsController *controller;
@property (nonatomic) BPLMapViewModel *mockModel;
@property (nonatomic) CLLocation *mockLocation;

@end

@implementation BPLSearchResultsControllerTest

- (void)setUp
{
  [super setUp];

  self.controller = [[BPLSearchResultsController alloc] init];
  self.mockModel = OCMClassMock([BPLMapViewModel class]);
  self.mockLocation = [[CLLocation alloc] initWithLatitude:51.5074 longitude:-0.1278];

  self.controller.model = self.mockModel;
  self.controller.currentLocation = self.mockLocation;

  // Load the view to trigger viewDidLoad
  [self.controller loadViewIfNeeded];
}

- (void)tearDown
{
  [super tearDown];
  self.controller = nil;
  self.mockModel = nil;
  self.mockLocation = nil;
}

#pragma mark - View Hierarchy Tests

- (void)testViewDidLoadInitializesCollectionView
{
  XCTAssertNotNil(self.controller.collectionView);
  XCTAssertEqualObjects(self.controller.view, self.controller.collectionView);
}

- (void)testCollectionViewHasProperLayout
{
  UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.controller.collectionView.collectionViewLayout;
  XCTAssertNotNil(layout);
  XCTAssertEqual(layout.scrollDirection, UICollectionViewScrollDirectionVertical);
  XCTAssertEqual(layout.minimumLineSpacing, 2.0f);
  XCTAssertEqual(layout.minimumInteritemSpacing, 0);
}

- (void)testCollectionViewHasProperBackgroundColor
{
  UIColor *expectedColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
  XCTAssertEqualObjects(self.controller.collectionView.backgroundColor, expectedColor);
}

- (void)testCollectionViewUsesAutoresizingMask
{
  XCTAssertTrue(self.controller.collectionView.translatesAutoresizingMaskIntoConstraints);
  XCTAssertEqual(self.controller.collectionView.autoresizingMask,
                 UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
}

- (void)testCollectionViewDataSourceIsSet
{
  XCTAssertEqualObjects(self.controller.collectionView.dataSource, self.controller);
}

- (void)testCollectionViewDelegateIsSet
{
  XCTAssertEqualObjects(self.controller.collectionView.delegate, self.controller);
}

#pragma mark - Data Source Tests

- (void)testNumberOfSections
{
  NSInteger sections = [self.controller numberOfSectionsInCollectionView:self.controller.collectionView];
  XCTAssertEqual(sections, 1);
}

- (void)testNumberOfItemsWithoutSearch
{
  OCMStub([self.mockModel numberOfPlacemarks]).andReturn(5);

  NSInteger items = [self.controller collectionView:self.controller.collectionView
                           numberOfItemsInSection:0];

  // Should be 5 placemarks + 1 "Find closest" cell
  XCTAssertEqual(items, 6);
}

- (void)testNumberOfItemsWithSearch
{
  OCMStub([self.mockModel numberOfPlacemarks]).andReturn(3); // Filtered result

  NSInteger items = [self.controller collectionView:self.controller.collectionView
                           numberOfItemsInSection:0];

  // Should be 3 filtered placemarks + 1 "Find closest" cell
  XCTAssertEqual(items, 4);
}

- (void)testNumberOfItemsWithNoPlacemarks
{
  OCMStub([self.mockModel numberOfPlacemarks]).andReturn(0);

  NSInteger items = [self.controller collectionView:self.controller.collectionView
                           numberOfItemsInSection:0];

  // Should be just the "Find closest" cell
  XCTAssertEqual(items, 1);
}

#pragma mark - Cell Configuration Tests

- (void)testFindClosestCellConfiguration
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  OCMStub([self.mockModel numberOfPlacemarks]).andReturn(5);

  UICollectionViewCell *cell = [self.controller collectionView:self.controller.collectionView
                                         cellForItemAtIndexPath:indexPath];

  XCTAssertNotNil(cell);
}

- (void)testPlacemarkCellConfiguration
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
  OCMStub([self.mockModel numberOfPlacemarks]).andReturn(5);

  BPLPlacemark *placemark = [BPLUnitTestHelper placemarkWithIdentifier:@"1"];
  OCMStub([self.mockModel placemarkForRowAtIndexPath:indexPath]).andReturn(placemark);

  UICollectionViewCell *cell = [self.controller collectionView:self.controller.collectionView
                                         cellForItemAtIndexPath:indexPath];

  XCTAssertNotNil(cell);
}

#pragma mark - Cell Size Tests

- (void)testCellSizeWithCurrentLocation
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  OCMStub([self.mockModel numberOfPlacemarks]).andReturn(5);

  CGSize size = [self.controller collectionView:self.controller.collectionView
                                         layout:self.controller.collectionView.collectionViewLayout
                         sizeForItemAtIndexPath:indexPath];

  // With current location, height should be 70
  XCTAssertEqual(size.height, 70.0f);
  XCTAssertGreaterThan(size.width, 0);
}

- (void)testCellSizeWithoutCurrentLocation
{
  self.controller.currentLocation = nil;
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  OCMStub([self.mockModel numberOfPlacemarks]).andReturn(5);

  CGSize size = [self.controller collectionView:self.controller.collectionView
                                         layout:self.controller.collectionView.collectionViewLayout
                         sizeForItemAtIndexPath:indexPath];

  // Without current location, height should be 50
  XCTAssertEqual(size.height, 50.0f);
  XCTAssertGreaterThan(size.width, 0);
}

- (void)testCellWidthAccountsForSectionInsets
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  OCMStub([self.mockModel numberOfPlacemarks]).andReturn(5);

  // Set collection view to a known width
  self.controller.collectionView.frame = CGRectMake(0, 0, 375, 600);

  CGSize size = [self.controller collectionView:self.controller.collectionView
                                         layout:self.controller.collectionView.collectionViewLayout
                         sizeForItemAtIndexPath:indexPath];

  // Width should be 375 - (8 left + 8 right) = 359
  XCTAssertEqual(size.width, 359.0f);
}

#pragma mark - Search Results Updating Tests

- (void)testUpdateSearchResultsWithValidSearchText
{
  BPLPlacemark *placemark1 = [BPLUnitTestHelper placemarkWithIdentifier:@"1"];
  BPLPlacemark *placemark2 = [BPLUnitTestHelper placemarkWithIdentifier:@"2"];

  UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:self.controller];
  searchController.searchBar.text = @"test";

  OCMStub([self.mockModel alphabeticallySortedPositions]).andReturn(@[placemark1, placemark2]);

  // Mock the filtering to return filtered results
  id modelMock = OCMPartialMock(self.mockModel);
  OCMStub([modelMock filteredData]).andReturn(@[placemark1]);

  [self.controller updateSearchResultsForSearchController:searchController];

  // Verify that the model's filteredData was set
  OCMVerify([modelMock filteredData]);
}

- (void)testUpdateSearchResultsWithEmptySearchText
{
  UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:self.controller];
  searchController.searchBar.text = @"";

  id modelMock = OCMPartialMock(self.mockModel);
  OCMExpect([modelMock setFilteredData:nil]);

  [self.controller updateSearchResultsForSearchController:searchController];

  OCMVerifyAll(modelMock);
}

#pragma mark - Delegate Tests

- (void)testCollectionViewSelectionHandling
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];

  __block BOOL selectionHandlerCalled = NO;
  self.controller.didSelectItemAtIndexPath = ^(NSIndexPath *selectedIndexPath) {
    selectionHandlerCalled = YES;
    XCTAssertEqualObjects(selectedIndexPath, indexPath);
  };

  [self.controller collectionView:self.controller.collectionView didSelectItemAtIndexPath:indexPath];

  XCTAssertTrue(selectionHandlerCalled);
}

#pragma mark - Property Tests

- (void)testModelProperty
{
  BPLMapViewModel *newModel = [[BPLMapViewModel alloc] init];
  self.controller.model = newModel;
  XCTAssertEqualObjects(self.controller.model, newModel);
}

- (void)testCurrentLocationProperty
{
  CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:40.7128 longitude:-74.0060];
  self.controller.currentLocation = newLocation;
  XCTAssertEqualObjects(self.controller.currentLocation, newLocation);
}

- (void)testCollectionViewProperty
{
  XCTAssertNotNil(self.controller.collectionView);
}

@end
