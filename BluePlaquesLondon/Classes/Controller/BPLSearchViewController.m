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

#import "BPLSearchViewController.h"

#import "BPLPlacemark.h"
#import "BPLPlacemark+Additions.h"
#import "UIColor+BPLColors.h"
#import "MKDistanceFormatter+BPLAdditions.h"
#import "BPLSearchResultCell.h"

static NSString *const kReusableIdentifierItem = @"itemCellIdentifier";

@interface BPLSearchViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation BPLSearchViewController

- (void)dealloc
{
  // Clean up references
  self.delegate = nil;
  self.model = nil;
  self.currentLocation = nil;
}

/**
 * Configures the collection view layout and appearance.
 */
- (void)viewDidLoad {
  [super viewDidLoad];

  // Configure collection view layout
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.minimumLineSpacing = 2.0f; // Small spacing between cards
  layout.minimumInteritemSpacing = 0;
  layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8); // Padding around collection
  self.collectionView.collectionViewLayout = layout;

  [self.collectionView registerClass:[BPLSearchResultCell class]
          forCellWithReuseIdentifier:kReusableIdentifierItem];

  self.collectionView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]; // Light gray background
}

#pragma mark - UICollectionViewDelegateFlowLayout

/**
 * Returns the size for collection view cells based on content requirements.
 * @param collectionView The collection view requesting size information
 * @param collectionViewLayout The layout object
 * @param indexPath The index path of the cell
 * @return Size for the cell at the specified index path
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat height = self.currentLocation ? 70.0f : 50.0f; // Two-line vs one-line height
  return CGSizeMake(collectionView.frame.size.width - 16, height); // Account for section insets
}

#pragma mark - <UICollectionViewDataSource>

/**
 * Returns the number of sections in the collection view.
 * @param collectionView The collection view requesting this information
 * @return Always returns 1 section
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

/**
 * Returns the number of items in the collection view section.
 * @param collectionView The collection view requesting this information
 * @param section The section index
 * @return Number of placemarks plus one for the "Find closest" cell
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.model.numberOfPlacemarks + 1; // +1 for "Find closest" cell
}

/**
 * Configures and returns a collection view cell for the specified index path.
 * @param collectionView The collection view requesting the cell
 * @param indexPath The index path of the cell
 * @return A configured collection view cell
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  BPLSearchResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReusableIdentifierItem
                                            forIndexPath:indexPath];

  NSString *title = @"";
  NSString *subtitle = @"";
  BOOL showSubtitle = NO;

  if (indexPath.row == 0) {
    title = NSLocalizedString(@"Find the plaque closest to me", nil);
    if (self.currentLocation) {
      subtitle = @"Navigate to nearest plaque";
      showSubtitle = YES;
    }
  } else {
    BPLPlacemark *pm = [self.model placemarkForRowAtIndexPath:indexPath];
    if (pm) {
      title = pm.placemarkName;
      if (self.currentLocation) {
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:pm.coordinate.latitude
                                                     longitude:pm.coordinate.longitude];
        subtitle = [MKDistanceFormatter distanceFromLocation:loc toLocation:self.currentLocation];
        showSubtitle = YES;
      }
    }
  }

  [cell configureCellWithTitle:title subtitle:subtitle showSubtitle:showSubtitle];

  return cell;
}



/**
 * Handles user selection of a collection view item.
 * @param collectionView The collection view containing the selected item
 * @param indexPath The index path of the selected item
 */
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  // Deselect the cell for visual feedback
  [collectionView deselectItemAtIndexPath:indexPath animated:YES];
  
  if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectItemAtIndexPath:)]) {
    [self.delegate searchViewController:self didSelectItemAtIndexPath:indexPath];
  }
}

@end
