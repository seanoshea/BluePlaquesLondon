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

@interface BPLSearchViewController ()

@end

@implementation BPLSearchViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.collectionView registerClass:[UICollectionViewCell class]
          forCellWithReuseIdentifier:kReusableIdentifierItem];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.model.numberOfPlacemarks + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewCell *cell =
  [collectionView dequeueReusableCellWithReuseIdentifier:kReusableIdentifierItem
                                            forIndexPath:indexPath];
  // TODO: Configure cell with native components
  if (indexPath.row == 0) {
    // Configure for "Find closest" cell
  } else {
    BPLPlacemark *pm = [self.model placemarkForRowAtIndexPath:indexPath];
    if (pm) {
      // Configure for placemark cell
    }
  }
  return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView cellHeightAtIndexPath:(NSIndexPath *)indexPath {
  return self.currentLocation ? 60.0f : 44.0f; // Standard cell heights
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
  if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectItemAtIndexPath:)]) {
    [self.delegate searchViewController:self didSelectItemAtIndexPath:indexPath];
  }
}

@end
