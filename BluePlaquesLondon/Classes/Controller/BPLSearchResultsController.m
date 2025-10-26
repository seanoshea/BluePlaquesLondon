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

#import "BPLSearchResultsController.h"
#import "BPLPlacemark.h"
#import "BPLPlacemark+Additions.h"
#import "BPLSearchResultCell.h"
#import "MKDistanceFormatter+BPLAdditions.h"

static NSString *const kReusableIdentifierItem = @"itemCellIdentifier";

@interface BPLSearchResultsController ()

@property (nonatomic) UICollectionView *collectionView;

@end

@implementation BPLSearchResultsController

- (instancetype)init
{
  self = [super init];
  if (self) {
    [self setupCollectionView];
  }
  return self;
}

- (void)setupCollectionView
{
  // Create collection view with flow layout
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.minimumLineSpacing = 2.0f;
  layout.minimumInteritemSpacing = 0;
  layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);

  _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
  _collectionView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
  _collectionView.dataSource = self;
  _collectionView.delegate = self;

  [_collectionView registerClass:[BPLSearchResultCell class]
      forCellWithReuseIdentifier:kReusableIdentifierItem];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view = self.collectionView;
}

- (void)dealloc
{
  self.didSelectItemAtIndexPath = nil;
  self.model = nil;
  self.currentLocation = nil;
  self.collectionView.dataSource = nil;
  self.collectionView.delegate = nil;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
  // Filter the data based on search text
  NSString *searchText = searchController.searchBar.text;
  if (searchText.length > 0) {
    self.model.filteredData = [self.model.alphabeticallySortedPositions
        filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.placemarkTitle contains[c] %@", searchText]];
  } else {
    self.model.filteredData = nil;
  }

  [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
  return self.model.numberOfPlacemarks + 1; // +1 for "Find closest" cell
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  BPLSearchResultCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:kReusableIdentifierItem
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

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  CGFloat height = self.currentLocation ? 70.0f : 50.0f;
  return CGSizeMake(collectionView.frame.size.width - 16, height);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  [collectionView deselectItemAtIndexPath:indexPath animated:YES];

  if (self.didSelectItemAtIndexPath) {
    self.didSelectItemAtIndexPath(indexPath);
  }
}

@end
