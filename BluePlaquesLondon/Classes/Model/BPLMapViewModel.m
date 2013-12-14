/*
 Copyright 2012 - 2013 UpwardsNorthwards
 
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

#import "SimpleKMLDocument.h"
#import "SimpleKMLPlacemark.h"
#import "SimpleKMLPoint.h"
#import "SimpleKMLStyle.h"
#import "SimpleKMLIconStyle.h"
#import "SimpleKMLLineStyle.h"
#import "SimpleKMLPolyStyle.h"
#import "SimpleKMLBalloonStyle.h"
#import "SimpleKMLFolder.h"

#import "NSString+MapOverlayAdditions.h"
#import "SimpleKMLPlacemark+Additions.h"

@interface BPLMapViewModel()

@property (nonatomic) SimpleKMLDocument *data;

@property (nonatomic, copy) NSMutableDictionary *coordinatesToArrayPositions;
@property (nonatomic, copy) NSMutableSet *councils;
@property (nonatomic, copy) NSMutableSet *years;
@property (nonatomic, copy) NSArray *alphabeticallySortedPositions;
@property (nonatomic, copy) NSMutableDictionary *coordinateToMarker;

@end

@implementation BPLMapViewModel

- (id)init
{
    self = [super init];
    if (self) {
        _coordinatesToArrayPositions = [@{} mutableCopy];
        _councils = [[NSMutableSet alloc] init];
        _years = [[NSMutableSet alloc] init];
        _coordinateToMarker = [@{} mutableCopy];
        [self loadBluePlaquesData];
    }
    return self;
}

- (NSError *)loadBluePlaquesData
{
    NSError *error;
    
    SimpleKML *kml = [SimpleKML KMLWithContentsOfFile:[[NSBundle mainBundle] pathForResource:BPLKMZFilename ofType:@"kmz"] error:&error];
    
    if (!error) {
        if (kml.feature && [kml.feature isKindOfClass:[SimpleKMLDocument class]]) {
            for (SimpleKMLFeature *feature in ((SimpleKMLContainer *)kml.feature).features) {
                if ([feature isKindOfClass:[SimpleKMLFolder class]]) {
                    self.data = ((SimpleKMLFolder *)feature).document;
                    break;
                }
            }
        }
    } else {
        
    }
    
    return error;
}

- (void)createMarkersForMap:(GMSMapView *)mapView
{
    // make sure there aren't any duplicates
    [self.data.flattenedPlacemarks enumerateObjectsUsingBlock:^(SimpleKMLPlacemark *placemark, NSUInteger idx, BOOL *stop) {
        
        NSArray *placemarksAssociatedWithKey = self.coordinatesToArrayPositions[placemark.key];
        if (!placemarksAssociatedWithKey) {
            [self.coordinatesToArrayPositions setObject:@[@(idx)] forKey:placemark.key];
        } else {
            NSMutableArray *newPlacemarks = [placemarksAssociatedWithKey mutableCopy];
            [newPlacemarks addObject:@(idx)];
            [self.coordinatesToArrayPositions setObject:newPlacemarks forKey:placemark.key];
        }
    }];
    
    // pop the markers on the map
    for (id key in self.coordinatesToArrayPositions) {
        
        id i = self.coordinatesToArrayPositions[key][0];
        
        SimpleKMLPlacemark *placemark = self.data.flattenedPlacemarks[[i intValue]];
        SimpleKMLPoint *point = placemark.point;
        
        GMSMarker *marker = [GMSMarker markerWithPosition:point.coordinate];
        marker.userData = placemark;
        marker.icon = placemark.style.iconStyle.icon;
        marker.title = placemark.title;
        marker.snippet = placemark.subtitle;
        marker.map = mapView;
        
        self.coordinateToMarker[placemark.key] = marker;
    }
}

- (NSInteger)numberOfPlacemarks
{
    return self.data.flattenedPlacemarks.count;
}

- (SimpleKMLPlacemark *)placemarkForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.alphabeticallySortedPositions) {
        self.alphabeticallySortedPositions = [self.data.flattenedPlacemarks sortedArrayUsingComparator:^NSComparisonResult(SimpleKMLPlacemark* one, SimpleKMLPlacemark* two) {
            return [one.name compare:two.name];
        }];
    }
    return self.alphabeticallySortedPositions[indexPath.row];
}

- (GMSMarker *)markerAtPlacemark:(SimpleKMLPlacemark *)placemark
{
    return self.coordinateToMarker[placemark.key];
}

@end
