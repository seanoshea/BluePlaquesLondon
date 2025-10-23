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
#import "BPLSearchViewController.h"
#import "BPLMapViewModel.h"
#import "BPLPlacemark+Additions.h"
#import "OCMock.h"

@interface BPLSearchViewControllerTest : XCTestCase <BPLSearchViewControllerDelegate>
@property (nonatomic) BPLSearchViewController *searchViewController;
@property (nonatomic) BPLMapViewModel *mockModel;
@property (nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation BPLSearchViewControllerTest

- (void)setUp
{
    [super setUp];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.searchViewController = [[BPLSearchViewController alloc] initWithCollectionViewLayout:layout];
    self.searchViewController.delegate = self;
    
    self.mockModel = OCMClassMock([BPLMapViewModel class]);
    OCMStub([self.mockModel numberOfPlacemarks]).andReturn(5);
    self.searchViewController.model = self.mockModel;
    
    [self.searchViewController loadViewIfNeeded];
}

- (void)testViewDidLoad
{
    XCTAssertNotNil(self.searchViewController.collectionView);
    XCTAssertNotNil(self.searchViewController.collectionView.collectionViewLayout);
}

- (void)testNumberOfSections
{
    NSInteger sections = [self.searchViewController numberOfSectionsInCollectionView:self.searchViewController.collectionView];
    XCTAssertEqual(sections, 1);
}

- (void)testNumberOfItems
{
    NSInteger items = [self.searchViewController collectionView:self.searchViewController.collectionView numberOfItemsInSection:0];
    XCTAssertEqual(items, 6); // 5 placemarks + 1 "Find closest" cell
}

- (void)testCellSize
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    CGSize size = [self.searchViewController collectionView:self.searchViewController.collectionView 
                                                     layout:self.searchViewController.collectionView.collectionViewLayout 
                                     sizeForItemAtIndexPath:indexPath];
    
    XCTAssertTrue(size.width > 0);
    XCTAssertTrue(size.height > 0);
}

- (void)testCellConfiguration
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UICollectionViewCell *cell = [self.searchViewController collectionView:self.searchViewController.collectionView 
                                                     cellForItemAtIndexPath:indexPath];
    
    XCTAssertNotNil(cell);
    XCTAssertEqual(cell.backgroundColor, [UIColor whiteColor]);
}

- (void)testDelegateCallOnSelection
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.searchViewController collectionView:self.searchViewController.collectionView didSelectItemAtIndexPath:indexPath];
    
    XCTAssertNotNil(self.selectedIndexPath);
    XCTAssertEqual(self.selectedIndexPath.row, 0);
}

#pragma mark - BPLSearchViewControllerDelegate

- (void)searchViewController:(BPLSearchViewController *)searchViewController didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
}

@end