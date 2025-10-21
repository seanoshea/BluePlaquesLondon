//
//  BPLSearchViewController.m
//  BluePlaquesLondon
//
//  Created by Sean O'Shea on 8/19/16.
//  Copyright © 2016 Sean O'Shea. All rights reserved.
//

#import "BPLSearchViewController.h"

#import "BPLPlacemark.h"
#import "BPLPlacemark+Additions.h"
#import "UIColor+BPLColors.h"
#import "MKDistanceFormatter+BPLAdditions.h"

static NSString *const kReusableIdentifierItem = @"itemCellIdentifier";

@interface BPLSearchViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation BPLSearchViewController

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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat height = self.currentLocation ? 70.0f : 50.0f; // Two-line vs one-line height
  return CGSizeMake(collectionView.frame.size.width - 16, height); // Account for section insets
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.model.numberOfPlacemarks + 1; // +1 for "Find closest" cell
}

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



- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  // Deselect the cell for visual feedback
  [collectionView deselectItemAtIndexPath:indexPath animated:YES];
  
  if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectItemAtIndexPath:)]) {
    [self.delegate searchViewController:self didSelectItemAtIndexPath:indexPath];
  }
}

@end
