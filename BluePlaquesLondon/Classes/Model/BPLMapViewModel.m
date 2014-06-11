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

#import "BPLMapViewModel.h"

#import "BPLConstants.h"
#import "BPLPlacemark.h"
#import "NSObject+BPLTracking.h"
#import "BPLConstants.h"
#import "BPLPlacemark+Additions.h"

@interface BPLMapViewModel()

@property (nonatomic) KMLRoot *data;
@property (nonatomic, copy) NSMutableDictionary *coordinateToMarker;
@property (nonatomic, copy) NSMutableDictionary *keyToArrayPositions;

@end

@implementation BPLMapViewModel

- (instancetype)initWithKMLFileParsedCallback:(dispatch_block_t)kmlFileParsedCallback
{
    self = [super init];
    if (self) {
        _coordinateToMarker = [@{} mutableCopy];
        _keyToArrayPositions = [@{} mutableCopy];
        _massagedData = [@[] mutableCopy];
        _kmlFileParsedCallback = [kmlFileParsedCallback copy];
        [self loadBluePlaquesData];
    }
    return self;
}

- (void)loadBluePlaquesData
{
    // can take some time to parse the kmz file ...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:BPLKMZFilename ofType:@"kml"]];
        self.data = [KMLParser parseKMLAtURL:url];
        if (self.kmlFileParsedCallback) {
            self.kmlFileParsedCallback();
        }
    });
}

- (void)createMarkersForMap:(GMSMapView *)mapView
{
    // make sure there aren't any duplicates
    [self.data.placemarks enumerateObjectsUsingBlock:^(KMLPlacemark *placemark, NSUInteger idx, BOOL *stop) {
        BPLPlacemark *bplPlacemark = [self bplPlacemarkFromKMLPlacemark:placemark];
        NSArray *placemarksAssociatedWithKey = self.keyToArrayPositions[bplPlacemark.key];
        if (!placemarksAssociatedWithKey) {
            [self.keyToArrayPositions setObject:@[@(idx)] forKey:bplPlacemark.key];
            [self.massagedData addObject:bplPlacemark];
        } else {
            NSArray *existingPlacemarks = self.keyToArrayPositions[bplPlacemark.key];
            BPLPlacemark *existingPlacemark = self.data.placemarks[[existingPlacemarks[0] intValue]];
            if (![existingPlacemark.title isEqualToString:bplPlacemark.title]) {
                NSMutableArray *newPlacemarks = [placemarksAssociatedWithKey mutableCopy];
                [newPlacemarks addObject:@(idx)];
                [self.keyToArrayPositions setObject:newPlacemarks forKey:bplPlacemark.key];
            }
        }
    }];
    
    // pop the markers on the map
    for (BPLPlacemark *placemark in self.massagedData) {
        
        GMSMarker *marker = [GMSMarker markerWithPosition:placemark.coordinate];
        marker.userData = placemark;
        marker.icon = [UIImage imageNamed:[placemark.styleUrl isEqualToString:@"#myDefaultStyles"] ? @"blue" : @"green"];
        marker.title = placemark.placemarkTitle;
        // check to see if the regular subtitle would be too big to pop into the snippet
        NSString *snippet;
        NSArray *numberOfPlacemarksAssociatedWithPlacemark = self.keyToArrayPositions[placemark.key];
        if (numberOfPlacemarksAssociatedWithPlacemark.count == 1) {
            snippet = placemark.occupation;
        } else {
            // generic message should suffice
            snippet = NSLocalizedString(@"Multiple Placemarks at this location", @"");
        }
        
        marker.snippet = snippet;
        marker.map = mapView;
        
        self.coordinateToMarker[placemark.key] = marker;
    }
}

- (NSInteger)numberOfPlacemarks
{
    return self.filteredData.count ?: self.massagedData.count;
}

- (BPLPlacemark *)placemarkForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.filteredData.count) {
        return self.filteredData[indexPath.row - 1];
    } else {
        return self.alphabeticallySortedPositions[indexPath.row - 1];
    }
}

- (GMSMarker *)markerAtPlacemark:(BPLPlacemark *)placemark
{
    return self.coordinateToMarker[placemark.key];
}

- (NSArray *)placemarksForKey:(NSString *)key
{
    NSArray *indices = self.keyToArrayPositions[key];
    NSMutableArray *placemarks = [NSMutableArray arrayWithCapacity:indices.count];
    for (NSNumber *index in indices) {
        BPLPlacemark *bplPlacemark = [self bplPlacemarkFromKMLPlacemark:self.data.placemarks[[index intValue]]];
        [placemarks addObject:bplPlacemark];
    }
    return placemarks;
}

- (BPLPlacemark *)closestPlacemarkToCoordinate:(CLLocationCoordinate2D)coordinate
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    BPLPlacemark *closestPlacemark;
    CLLocationDistance currentDistance;
    for (BPLPlacemark *placemark in self.alphabeticallySortedPositions) {
        
        CLLocation *placemarkLocation = [[CLLocation alloc] initWithLatitude:placemark.coordinate.latitude longitude:placemark.coordinate.longitude];
        CLLocationDistance distance = [location distanceFromLocation:placemarkLocation];
        if (!closestPlacemark) {
            currentDistance = distance;
            closestPlacemark = placemark;
        } else if (distance < currentDistance) {
            currentDistance = distance;
            closestPlacemark = placemark;
        }
    }
    return closestPlacemark;
}

- (BPLPlacemark *)firstPlacemarkAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    BPLPlacemark *firstPlacemark;
    for (BPLPlacemark *placemark in self.alphabeticallySortedPositions) {
        if (placemark.coordinate.latitude == coordinate.latitude &&
            placemark.coordinate.longitude == coordinate.longitude) {
            firstPlacemark = placemark;
        }
    }
    return firstPlacemark;
}

- (NSArray *)alphabeticallySortedPositions
{
    if (!_alphabeticallySortedPositions) {
        _alphabeticallySortedPositions = [self.massagedData sortedArrayUsingComparator:^NSComparisonResult(KMLPlacemark* one, KMLPlacemark* two) {
            return [one.name compare:two.name];
        }];
    }
    return _alphabeticallySortedPositions;
}

- (BPLPlacemark *)bplPlacemarkFromKMLPlacemark:(KMLPlacemark *)placemark
{
    BPLPlacemark *bplPlacemark = [[BPLPlacemark alloc] init];
    KMLPoint *geometry = (KMLPoint *)placemark.geometry;
    
    bplPlacemark.featureDescription = placemark.descriptionValue;
    bplPlacemark.name = placemark.name;
    bplPlacemark.styleUrl = placemark.styleUrl;
    bplPlacemark.latitude = [[NSNumber alloc] initWithDouble: geometry.coordinate.latitude];
    bplPlacemark.longitude = [[NSNumber alloc] initWithDouble: geometry.coordinate.longitude];
    
    return bplPlacemark;
}

@end
