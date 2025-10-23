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

#import "BPLDetailChooserViewController.h"

#import "UIColor+BPLColors.h"
#import "BPLConstants.h"
#import "BPLPlacemark.h"
#import "BPLPlacemark+Additions.h"
// Material Components removed as per modernization plan

static NSString *const kReusableIdentifierItem = @"itemCellIdentifier";

static NSString *const BPLMultipleCell = @"BluePlaquesLondonMultipleCell";

NSString *BPLDetailChooserViewControllerStoryboardIdentifier = @"BPLDetailChooserViewController";

@implementation BPLDetailChooserViewController

#pragma mark Lifecycle

/**
 * Configures the collection view and registers cell classes.
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  [self.collectionView registerClass:[UICollectionViewCell class]
          forCellWithReuseIdentifier:kReusableIdentifierItem];
}

/**
 * Sets the navigation title when the view is about to appear.
 * @param animated Whether the appearance is animated
 */
- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.title = NSLocalizedString(@"Choose one", nil);
}

/**
 * Reloads collection view data when the view appears.
 * @param animated Whether the appearance is animated
 */
- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  // Google Analytics tracking removed as per modernization plan
  [self.collectionView reloadData];
}

#pragma mark UICollectionViewDataSource

/**
 * Returns the number of sections in the collection view.
 * @param collectionView The collection view requesting this information
 * @return Always returns 1 section
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

/**
 * Returns the number of items in the specified section.
 * @param collectionView The collection view requesting this information
 * @param section The index of the section
 * @return The number of markers to display
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.markers.count;
}

/**
 * Returns the height for cells in the collection view.
 * @param collectionView The collection view requesting this information
 * @param indexPath The index path of the cell
 * @return Standard cell height of 44 points
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView cellHeightAtIndexPath:(NSIndexPath *)indexPath {
  return 44.0f; // Standard cell height
}

/**
 * Configures and returns a cell for the specified index path.
 * @param collectionView The collection view requesting the cell
 * @param indexPath The index path specifying the location of the cell
 * @return A configured collection view cell
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewCell *cell =
  [collectionView dequeueReusableCellWithReuseIdentifier:kReusableIdentifierItem
                                            forIndexPath:indexPath];
  // Configure cell with native components
  BPLPlacemark *pm = self.markers[indexPath.row];
  // TODO: Add proper cell configuration with native UI components
  return cell;
}

#pragma mark UICollectionViewDelegate

/**
 * Handles selection of a collection view item by posting a notification
 * and navigating back to the previous view controller.
 * @param collectionView The collection view containing the selected item
 * @param indexPath The index path of the selected item
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
  [[NSNotificationCenter defaultCenter] postNotificationName:BPLDetailChooserViewControllerRowSelected object:@(indexPath.row)];
  [self.navigationController popViewControllerAnimated:YES];
}

@end
