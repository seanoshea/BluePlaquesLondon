//
//  BPLSearchViewController.h
//  BluePlaquesLondon
//
//  Created by Sean O'Shea on 8/19/16.
//  Copyright © 2016 Sean O'Shea. All rights reserved.
//

#import "MaterialCollections.h"

#import "BPLMapViewModel.h"

@class BPLSearchViewController;

@protocol BPLSearchViewControllerDelegate <NSObject>

- (void)searchViewController:(BPLSearchViewController *)searchViewController
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface BPLSearchViewController : MDCCollectionViewController

@property (nonatomic, weak) id<BPLSearchViewControllerDelegate> delegate;
@property (nonatomic) BPLMapViewModel *model;
@property (nonatomic) CLLocation *currentLocation;

@end
