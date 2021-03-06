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
#import "MDCCollectionViewTextCell.h"

#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <GoogleAnalytics/GAIFields.h>

static NSString *const kReusableIdentifierItem = @"itemCellIdentifier";

static NSString *const BPLMultipleCell = @"BluePlaquesLondonMultipleCell";

NSString *BPLDetailChooserViewControllerStoryboardIdentifier = @"BPLDetailChooserViewController";

@implementation BPLDetailChooserViewController

#pragma mark Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.collectionView registerClass:[MDCCollectionViewTextCell class]
          forCellWithReuseIdentifier:kReusableIdentifierItem];
  self.styler.cellStyle = MDCCollectionViewCellStyleCard;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.title = NSLocalizedString(@"Choose one", nil);
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  id tracker = [GAI sharedInstance].defaultTracker;
  [tracker set:kGAIScreenName value:@"Multiple Placemarks Screen"];
  [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
  [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.markers.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView cellHeightAtIndexPath:(NSIndexPath *)indexPath {
  return MDCCellDefaultOneLineHeight;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  MDCCollectionViewTextCell *cell =
  [collectionView dequeueReusableCellWithReuseIdentifier:kReusableIdentifierItem
                                            forIndexPath:indexPath];
  cell.accessoryType = MDCCollectionViewCellAccessoryDisclosureIndicator;
  cell.textLabel.textColor = [UIColor BPLBlueColour];
  cell.inkView.inkColor = [UIColor BPLLightOrangeColour];
  BPLPlacemark *pm = self.markers[indexPath.row];
  cell.textLabel.text = pm.placemarkName;
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
  [[NSNotificationCenter defaultCenter] postNotificationName:BPLDetailChooserViewControllerRowSelected object:@(indexPath.row)];
  [self.navigationController popViewControllerAnimated:YES];
}

@end
