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

#import "BPLMapViewModel.h"

#import "SimpleKMLPlacemark+Additions.h"
#import "SimpleKMLPoint.h"
#import "NSUserDefaults+BPLState.h"
#import "BPLMapViewDetailViewController.h"
#import "BPLConstants.h"

@interface BPLMapViewController() <GMSMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic) BPLMapViewModel *model;

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.model.numberOfPlacemarks;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    SimpleKMLPlacemark *pm = [self.model placemarkForRowAtIndexPath:indexPath];
    cell.textLabel.text = pm.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SimpleKMLPlacemark *pm = [self.model placemarkForRowAtIndexPath:indexPath];
    self.tableView.hidden = YES;
    [self.searchBar resignFirstResponder];
    [self.mapView animateToLocation:pm.point.coordinate];
    self.mapView.selectedMarker = [self.model markerAtPlacemark:pm];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self filterDataForSearchText:searchBar.text];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self toggleTableView:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self filterDataForSearchText:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterDataForSearchText:searchText];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self toggleTableView:NO];
}

- (void)filterDataForSearchText:(NSString *)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@", searchText];
    self.model.filteredData = [self.model.massagedData filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}

- (void)toggleTableView:(BOOL)show
{
    if (show) {
        [self.view bringSubviewToFront:self.tableView];
    } else {
        [self.view sendSubviewToBack:self.tableView];
    }
    self.searchBar.showsCancelButton = show;
    self.tableView.hidden = !show;
}

- (void)commonInit
{
    self.model = [[BPLMapViewModel alloc] init];
    
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

    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
    
    self.mapView.delegate = self;
    self.mapView.indoorEnabled = NO;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = YES;
    [self.view addSubview:self.mapView];
    [self.mapView animateToLocation:lastKnownCoordinate];
    [self.model createMarkersForMap:self.mapView];
    
    self.searchBar.placeholder = NSLocalizedString(@"Search", @"");
    [self.view bringSubviewToFront:self.searchBar];
    [self toggleTableView:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:BPLMapDetailViewControllerSegue]) {
        BPLMapViewDetailViewController *destinationViewController = (BPLMapViewDetailViewController *)segue.destinationViewController;
        destinationViewController.marker = self.mapView.selectedMarker;
    }
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
    [[NSUserDefaults standardUserDefaults] saveLastKnownBPLCoordinate:marker.position];
    return NO;
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    if (position.zoom > 0.0f) {
        [[NSUserDefaults standardUserDefaults] saveMapZoom:position.zoom];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {

    [[NSUserDefaults standardUserDefaults] saveLastKnownBPLCoordinate:marker.position];
    [self performSegueWithIdentifier:BPLMapDetailViewControllerSegue sender:self];
}

@end
