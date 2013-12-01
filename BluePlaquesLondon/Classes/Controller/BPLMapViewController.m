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

#import "BPLAppDelegate.h"
#import "BPLModel.h"
#import "SimpleKMLDocument.h"
#import "SimpleKMLPlacemark.h"
#import "SimpleKMLPoint.h"
#import "NSUserDefaults+BPLState.h"
#import "NSString+MapOverlayAdditions.h"

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

- (void)commonInit
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    CLLocationCoordinate2D lastKnownCoordinate = [defaults lastKnownBPLCoordinate];
    float mapZoom = [defaults mapZoom];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lastKnownCoordinate.latitude
                                                            longitude:lastKnownCoordinate.longitude
                                                                 zoom:mapZoom];
    
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    self.mapView.delegate = self;
    self.mapView.indoorEnabled = NO;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = YES;
    
    self.view = self.mapView;
    
    [self.mapView animateToLocation:lastKnownCoordinate];
    
    [self dummy];
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
    [[NSUserDefaults standardUserDefaults] saveLastKnownCoordinate:self.currentLocation.coordinate];
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)cameraPosition
{
    
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [[NSUserDefaults standardUserDefaults] saveLastKnownCoordinate:self.currentLocation.coordinate];
    return NO;
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    if (position.zoom > 0.0f) {
        [[NSUserDefaults standardUserDefaults] saveMapZoom:position.zoom];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    
}

- (void)dummy
{
    BPLAppDelegate *appDelegate = (BPLAppDelegate *)[[UIApplication sharedApplication] delegate];
    BPLModel *model = appDelegate.bplModel;
    for (SimpleKMLPlacemark *pm in model.data.flattenedPlacemarks) {
        SimpleKMLPoint *point = pm.point;

        GMSMarker *marker = [GMSMarker markerWithPosition:point.coordinate];
        
        marker.title = [pm.featureDescription overlayTitle];
        marker.snippet = [pm.featureDescription overlaySubtitle];
        
        marker.map = self.mapView;
    }
}

@end
