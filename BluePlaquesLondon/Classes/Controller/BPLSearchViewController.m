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

static NSString *const kReusableIdentifierItem = @"itemCellIdentifier";

@interface BPLSearchViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation BPLSearchViewController

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
  
  [self.collectionView registerClass:[UICollectionViewCell class]
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
  UICollectionViewCell *cell =
  [collectionView dequeueReusableCellWithReuseIdentifier:kReusableIdentifierItem
                                            forIndexPath:indexPath];
  
  // Remove existing subviews
  for (UIView *subview in cell.contentView.subviews) {
    [subview removeFromSuperview];
  }
  
  // Card-like styling
  cell.backgroundColor = [UIColor whiteColor];
  cell.layer.cornerRadius = 8.0f;
  cell.layer.shadowColor = [UIColor blackColor].CGColor;
  cell.layer.shadowOffset = CGSizeMake(0, 2);
  cell.layer.shadowRadius = 4.0f;
  cell.layer.shadowOpacity = 0.1f;
  
  // Configure labels
  CGFloat cellWidth = cell.frame.size.width;
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, cellWidth - 48, 20)];
  UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 28, cellWidth - 48, 16)];
  
  titleLabel.font = [UIFont boldSystemFontOfSize:16];
  titleLabel.textColor = [UIColor BPLBlueColour];
  subtitleLabel.font = [UIFont systemFontOfSize:14];
  subtitleLabel.textColor = [UIColor BPLDarkGreyColour];
  titleLabel.numberOfLines = 1;
  subtitleLabel.numberOfLines = 1;
  
  // Add disclosure indicator
  UILabel *disclosureLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth - 30, 0, 20, cell.frame.size.height)];
  disclosureLabel.text = @">";
  disclosureLabel.textColor = [UIColor lightGrayColor];
  disclosureLabel.textAlignment = NSTextAlignmentCenter;
  disclosureLabel.font = [UIFont boldSystemFontOfSize:18];
  
  if (indexPath.row == 0) {
    titleLabel.text = NSLocalizedString(@"Find the plaque closest to me", nil);
    if (self.currentLocation) {
      subtitleLabel.text = @"Navigate to nearest plaque";
    } else {
      subtitleLabel.text = @"";
    }
  } else {
    BPLPlacemark *pm = [self.model placemarkForRowAtIndexPath:indexPath];
    if (pm) {
      titleLabel.text = pm.placemarkName;
      if (self.currentLocation) {
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:pm.coordinate.latitude
                                                     longitude:pm.coordinate.longitude];
        subtitleLabel.text = [MKDistanceFormatter distanceFromLocation:loc toLocation:self.currentLocation];
      } else {
        subtitleLabel.text = @"";
      }
    }
  }
  
  [cell.contentView addSubview:titleLabel];
  if (self.currentLocation || indexPath.row == 0) {
    [cell.contentView addSubview:subtitleLabel];
  }
  [cell.contentView addSubview:disclosureLabel];
  
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
