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

#import "BPLAppDelegate.h"
#import "BPLModel.h"
#import "SimpleKMLDocument.h"
#import "SimpleKMLPlacemark.h"
#import "SimpleKMLPoint.h"
#import "SimpleKMLStyle.h"
#import "SimpleKMLIconStyle.h"
#import "SimpleKMLLineStyle.h"
#import "SimpleKMLPolyStyle.h"
#import "SimpleKMLBalloonStyle.h"
#import "NSString+MapOverlayAdditions.h"
#import "SimpleKMLPlacemark+Additions.h"

@interface BPLMapViewModel()

@property (nonatomic, copy) NSMutableDictionary *coordinatesToArrayPositions;
@property (nonatomic, copy) NSMutableSet *councils;
@property (nonatomic, copy) NSMutableSet *years;

@end

@implementation BPLMapViewModel

- (id)init
{
    self = [super init];
    if (self) {
        _coordinatesToArrayPositions = [@{} mutableCopy];
        _councils = [[NSMutableSet alloc] init];
        _years = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)createMarkersForMap:(GMSMapView *)mapView
{
    BPLAppDelegate *appDelegate = (BPLAppDelegate *)[[UIApplication sharedApplication] delegate];
    BPLModel *model = appDelegate.bplModel;
    
    // make sure there aren't any duplicates
    [model.data.flattenedPlacemarks enumerateObjectsUsingBlock:^(SimpleKMLPlacemark *placemark, NSUInteger idx, BOOL *stop) {
        
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
        
        SimpleKMLPlacemark *placemark = model.data.flattenedPlacemarks[[i intValue]];
        SimpleKMLPoint *point = placemark.point;
        
        GMSMarker *marker = [GMSMarker markerWithPosition:point.coordinate];
        marker.userData = placemark;
        marker.icon = placemark.style.iconStyle.icon;
        marker.title = placemark.title;
        marker.snippet = placemark.subtitle;
        
        marker.map = mapView;
    }
}

@end
