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

#import "SimpleKMLDocument.h"
#import "SimpleKMLPlacemark.h"
#import "SimpleKMLPoint.h"
#import "SimpleKMLStyle.h"
#import "SimpleKMLIconStyle.h"
#import "SimpleKMLLineStyle.h"
#import "SimpleKMLPolyStyle.h"
#import "SimpleKMLBalloonStyle.h"
#import "SimpleKMLFolder.h"

#import "NSObject+BPLTracking.h"
#import "BPLConstants.h"

#import "SimpleKMLPlacemark+BPLAdditions.h"

@interface BPLMapViewModel()

@property (nonatomic) SimpleKMLDocument *data;
@property (nonatomic, copy) NSMutableDictionary *coordinateToMarker;
@property (nonatomic, copy) NSMutableDictionary *keyToArrayPositions;

@end

@implementation BPLMapViewModel

- (instancetype)initWithKMZFileParsedCallback:(dispatch_block_t)kmzFileParsedCallback
{
    self = [super init];
    if (self) {
        _coordinateToMarker = [@{} mutableCopy];
        _keyToArrayPositions = [@{} mutableCopy];
        _massagedData = [@[] mutableCopy];
        _kmzFileParsedCallback = [kmzFileParsedCallback copy];
        [self loadBluePlaquesData];
    }
    return self;
}

- (void)loadBluePlaquesData
{
    // can take some time to parse the kmz file ...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDate *methodStart = [NSDate date];
        
        SimpleKML *kml = [SimpleKML KMLWithContentsOfFile:[[NSBundle mainBundle] pathForResource:BPLKMZFilename ofType:@"kmz"] error:nil];
        
        NSNumber *number = [[NSNumber alloc] initWithDouble:[[NSDate date] timeIntervalSinceDate:methodStart]];
        [self trackCategory:BPLKMZFileParsing action:BPLKMZFileParsingEvent label:BPLKMZFileParsing value:number];

        if (kml.feature && [kml.feature isKindOfClass:[SimpleKMLDocument class]]) {
            for (SimpleKMLFeature *feature in ((SimpleKMLContainer *)kml.feature).features) {
                if ([feature isKindOfClass:[SimpleKMLFolder class]]) {
                    self.data = ((SimpleKMLFolder *)feature).document;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.kmzFileParsedCallback) {
                            self.kmzFileParsedCallback();
                        }
                    });
                    break;
                }
            }
        }
    });
}

- (void)createMarkersForMap:(GMSMapView *)mapView
{
    // make sure there aren't any duplicates
    [self.data.flattenedPlacemarks enumerateObjectsUsingBlock:^(SimpleKMLPlacemark *placemark, NSUInteger idx, BOOL *stop) {
        NSArray *placemarksAssociatedWithKey = self.keyToArrayPositions[placemark.key];
        if (!placemarksAssociatedWithKey) {
            [self.keyToArrayPositions setObject:@[@(idx)] forKey:placemark.key];
            [self.massagedData addObject:placemark];
        } else {
            NSArray *existingPlacemarks = self.keyToArrayPositions[placemark.key];
            SimpleKMLPlacemark *existingPlacemark = self.data.flattenedPlacemarks[[existingPlacemarks[0] intValue]];
            if (![existingPlacemark.title isEqualToString:placemark.title]) {
                NSMutableArray *newPlacemarks = [placemarksAssociatedWithKey mutableCopy];
                [newPlacemarks addObject:@(idx)];
                [self.keyToArrayPositions setObject:newPlacemarks forKey:placemark.key];
            }
        }
    }];
    
    // pop the markers on the map
    for (SimpleKMLPlacemark *placemark in self.massagedData) {
        SimpleKMLPoint *point = placemark.point;
        
        GMSMarker *marker = [GMSMarker markerWithPosition:point.coordinate];
        marker.userData = placemark;
        marker.icon = placemark.style.iconStyle.icon;
        marker.title = placemark.title;
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

- (SimpleKMLPlacemark *)placemarkForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.filteredData.count) {
        return self.filteredData[indexPath.row - 1];
    } else {
        return self.alphabeticallySortedPositions[indexPath.row - 1];
    }
}

- (GMSMarker *)markerAtPlacemark:(SimpleKMLPlacemark *)placemark
{
    return self.coordinateToMarker[placemark.key];
}

- (NSArray *)placemarksForKey:(NSString *)key
{
    NSArray *indices = self.keyToArrayPositions[key];
    NSMutableArray *placemarks = [NSMutableArray arrayWithCapacity:indices.count];
    for (NSNumber *index in indices) {
        [placemarks addObject:self.data.flattenedPlacemarks[[index intValue]]];
    }
    return placemarks;
}

- (SimpleKMLPlacemark *)closestPlacemarkToCoordinate:(CLLocationCoordinate2D)coordinate
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    SimpleKMLPlacemark *closestPlacemark;
    CLLocationDistance currentDistance;
    for (SimpleKMLPlacemark *placemark in self.alphabeticallySortedPositions) {
        CLLocation *placemarkLocation = [[CLLocation alloc] initWithLatitude:placemark.point.coordinate.latitude longitude:placemark.point.coordinate.longitude];
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

- (SimpleKMLPlacemark *)firstPlacemarkAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    SimpleKMLPlacemark *firstPlacemark;
    for (SimpleKMLPlacemark *placemark in self.alphabeticallySortedPositions) {
        if (placemark.point.coordinate.latitude == coordinate.latitude &&
            placemark.point.coordinate.longitude == coordinate.longitude) {
            firstPlacemark = placemark;
        }
    }
    return firstPlacemark;
}

- (NSArray *)alphabeticallySortedPositions
{
    if (!_alphabeticallySortedPositions) {
        _alphabeticallySortedPositions = [self.massagedData sortedArrayUsingComparator:^NSComparisonResult(SimpleKMLPlacemark* one, SimpleKMLPlacemark* two) {
            return [one.name compare:two.name];
        }];
    }
    return _alphabeticallySortedPositions;
}

@end
