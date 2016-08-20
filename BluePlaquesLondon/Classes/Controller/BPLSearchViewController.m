//
//  BPLSearchViewController.m
//  BluePlaquesLondon
//
//  Created by Sean O'Shea on 8/19/16.
//  Copyright © 2016 Sean O'Shea. All rights reserved.
//

#import "BPLSearchViewController.h"

#import "MaterialSwitch.h"
#import "BPLPlacemark.h"
#import "BPLPlacemark+Additions.h"
#import "UIColor+BPLColors.h"

static NSString *const kReusableIdentifierItem = @"itemCellIdentifier";

@interface BPLSearchViewController ()

@end

@implementation BPLSearchViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.collectionView registerClass:[MDCCollectionViewTextCell class]
          forCellWithReuseIdentifier:kReusableIdentifierItem];
  self.styler.cellStyle = MDCCollectionViewCellStyleCard;
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
  MDCCollectionViewTextCell *cell =
  [collectionView dequeueReusableCellWithReuseIdentifier:kReusableIdentifierItem
                                            forIndexPath:indexPath];
  cell.accessoryType = MDCCollectionViewCellAccessoryDisclosureIndicator;
  cell.textLabel.textColor = [UIColor BPLBlueColour];
  cell.inkView.inkColor = [UIColor BPLLightOrangeColour];
  if (indexPath.row == 0) {
    cell.textLabel.text = NSLocalizedString(@"Find the plaque closest to me", nil);
  } else {
    BPLPlacemark *pm = [self.model placemarkForRowAtIndexPath:indexPath];
    if (pm) {
      cell.textLabel.text = pm.placemarkName;
    }
  }
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
  return;
  if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectItemAtIndexPath:)]) {
    [self.delegate searchViewController:self didSelectItemAtIndexPath:indexPath];
  }
}

@end
