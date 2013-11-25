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

#import "BPLMapViewController.h"

@interface BPLMapViewController() <GMSMapViewDelegate, CLLocationManagerDelegate>
    @property (nonatomic) CLLocationManager *locationManager;
    @property (nonatomic) GMSMapView *mapView;
    @property (nonatomic) CLLocation *currentLocation;
@end

@implementation BPLMapViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:15];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    self.mapView.delegate = self;
    self.mapView.indoorEnabled = NO;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = YES;
    
    self.view = self.mapView;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if (!self.currentLocation) {
        self.currentLocation = [locations lastObject];
    }
    
    for (CLLocation *recordedLocation in locations) {
        if (recordedLocation.horizontalAccuracy < self.currentLocation.horizontalAccuracy) {
            self.currentLocation = recordedLocation;
        }
    }
    
    [self.mapView animateToLocation:self.currentLocation.coordinate];
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
    
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    return YES;
}

@end
