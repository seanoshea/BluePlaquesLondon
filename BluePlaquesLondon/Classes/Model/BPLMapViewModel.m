/*
 Copyright (c) 2014 - 2015 Upwards Northwards Software Limited
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
            self.keyToArrayPositions[bplPlacemark.key] = @[@(idx)];
            [self.massagedData addObject:bplPlacemark];
        } else {
            NSArray *existingPlacemarks = self.keyToArrayPositions[bplPlacemark.key];
            BPLPlacemark *existingPlacemark = self.data.placemarks[[existingPlacemarks[0] intValue]];
            if (![existingPlacemark.title isEqualToString:bplPlacemark.title]) {
                NSMutableArray *newPlacemarks = [placemarksAssociatedWithKey mutableCopy];
                [newPlacemarks addObject:@(idx)];
                (self.keyToArrayPositions)[bplPlacemark.key] = newPlacemarks;
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
    return (self.filteredData).count ?: (self.massagedData).count;
}

- (BPLPlacemark *)placemarkForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BPLPlacemark *placemark;
    if ((self.filteredData).count) {
        placemark = self.filteredData[indexPath.row - 1];
    } else if ((self.alphabeticallySortedPositions).count > indexPath.row - 1) {
        placemark = self.alphabeticallySortedPositions[indexPath.row - 1];
    }
    if (!placemark) {
        NSLog(@"Placemark was requested at %ld, but no placemark found", (long)indexPath.row);
    }
    return placemark;
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
        BPLPlacemark *bplPlacemark = [self bplPlacemarkFromKMLPlacemark:self.data.placemarks[index.intValue]];
        [placemarks addObject:bplPlacemark];
    }
    return placemarks;
}

- (BPLPlacemark *)closestPlacemarkToCoordinate:(CLLocationCoordinate2D)coordinate
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    BPLPlacemark *closestPlacemark;
    CLLocationDistance currentDistance = -1;
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
    if (!_alphabeticallySortedPositions || _alphabeticallySortedPositions.count == 0) {
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
    bplPlacemark.latitude = [[NSNumber alloc] initWithDouble:geometry.coordinate.latitude];
    bplPlacemark.longitude = [[NSNumber alloc] initWithFloat:geometry.coordinate.longitude];
    
    return bplPlacemark;
}

@end
