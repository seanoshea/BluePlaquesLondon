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

#import <GoogleMaps/GoogleMaps.h>

@class BPLPlacemark;

#import <MapKit/MapKit.h>
#import <zlib.h>
#import "KML.h"

/**
 * View model that manages blue plaque data, map markers, and search functionality.
 * Handles KML file parsing, marker creation, and provides data access methods.
 */
@interface BPLMapViewModel : NSObject

/// Processed array of unique plaque locations
@property (nonatomic) NSMutableArray *massagedData;
/// Alphabetically sorted array of all placemarks
@property (nonatomic, copy) NSArray *alphabeticallySortedPositions;
/// Filtered array based on search criteria
@property (nonatomic, copy) NSArray *filteredData;
/// Callback block executed when KML file parsing completes
@property (nonatomic, copy) dispatch_block_t kmlFileParsedCallback;
/// Total number of placemarks available for display
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger numberOfPlacemarks;

/**
 * Designated initializer that creates a view model with a completion callback.
 * @param kmlFileParsedCallback Block to execute when KML parsing completes
 * @return Initialized BPLMapViewModel instance
 */
- (instancetype)initWithKMLFileParsedCallback:(dispatch_block_t)kmlFileParsedCallback NS_DESIGNATED_INITIALIZER;

/**
 * Creates and adds map markers to the provided Google Maps view.
 * @param mapView The Google Maps view to add markers to
 */
- (void)createMarkersForMap:(GMSMapView *)mapView;

/**
 * Returns the placemark at the specified index path in the filtered or sorted data.
 * @param indexPath The index path of the desired placemark
 * @return BPLPlacemark object at the specified index path
 */
- (BPLPlacemark *)placemarkForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Finds the closest placemark to the given coordinate.
 * @param coordinate The coordinate to search from
 * @return The closest BPLPlacemark object
 */
- (BPLPlacemark *)closestPlacemarkToCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 * Returns the first placemark found at the exact coordinate.
 * @param coordinate The coordinate to search for
 * @return BPLPlacemark object at the coordinate, or nil if none found
 */
- (BPLPlacemark *)firstPlacemarkAtCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 * Returns the Google Maps marker associated with the given placemark.
 * @param placemark The placemark to find the marker for
 * @return GMSMarker object associated with the placemark
 */
- (GMSMarker *)markerAtPlacemark:(BPLPlacemark *)placemark;

/**
 * Returns all placemarks associated with the given location key.
 * @param key The location key to search for
 * @return Array of BPLPlacemark objects at the location
 */
- (NSArray *)placemarksForKey:(NSString *)key;

@end
