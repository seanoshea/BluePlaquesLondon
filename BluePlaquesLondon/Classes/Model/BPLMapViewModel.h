/*
 Copyright 2013 - 2014 Sean O' Shea
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

#import <GoogleMaps/GoogleMaps.h>
#import "BPLPlacemark.h"

#import <MapKit/MapKit.h>
#import <zlib.h>
#import "KML.h"

@interface BPLMapViewModel : NSObject

@property (nonatomic, copy) NSMutableArray *massagedData;
@property (nonatomic, copy) NSArray *alphabeticallySortedPositions;
@property (nonatomic, copy) NSArray *filteredData;
@property (nonatomic, copy) dispatch_block_t kmzFileParsedCallback;

- (instancetype)initWithKMZFileParsedCallback:(dispatch_block_t)kmzFileParsedCallback;

- (void)createMarkersForMap:(GMSMapView *)mapView;

- (NSInteger)numberOfPlacemarks;
- (BPLPlacemark *)placemarkForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BPLPlacemark *)closestPlacemarkToCoordinate:(CLLocationCoordinate2D)coordinate;
- (BPLPlacemark *)firstPlacemarkAtCoordinate:(CLLocationCoordinate2D)coordinate;
- (GMSMarker *)markerAtPlacemark:(BPLPlacemark *)placemark;
- (NSArray *)placemarksForKey:(NSString *)key;

@end
