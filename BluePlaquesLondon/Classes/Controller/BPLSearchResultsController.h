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

#import <UIKit/UIKit.h>
#import "BPLMapViewModel.h"

/**
 * Callback for search result selection.
 * @param indexPath The index path of the selected search result
 */
typedef void(^BPLSearchResultSelectionHandler)(NSIndexPath *indexPath);

/**
 * View controller for displaying and managing search results in a collection view.
 * Works with UISearchController to provide search result updates and selection handling.
 * Conforms to UISearchResultsUpdating to handle search text changes.
 */
@interface BPLSearchResultsController : UIViewController <UISearchResultsUpdating, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

/// View model containing plaque data and search functionality
@property (nonatomic) BPLMapViewModel *model;
/// Current user location for distance calculations
@property (nonatomic) CLLocation *currentLocation;
/// Callback block invoked when a search result is selected
@property (nonatomic, copy) BPLSearchResultSelectionHandler didSelectItemAtIndexPath;
/// The underlying collection view for search results
@property (nonatomic, readonly) UICollectionView *collectionView;

/**
 * Initializes the search results controller.
 * @return Initialized instance
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 * Updates search results based on the search controller's search text.
 * Automatically called by UISearchResultsUpdating protocol.
 * @param searchController The search controller providing the search text
 */
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController;

@end
